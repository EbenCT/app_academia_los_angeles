// lib/screens/courses/dynamic_lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/screens/screen_base.dart';
import '../../providers/student_provider.dart';
import '../../providers/coin_provider.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../services/topic_lesson_service.dart';
import '../../services/graphql_service.dart';

class DynamicLessonScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onComplete;

  const DynamicLessonScreen({
    super.key,
    required this.lesson,
    required this.onComplete,
  });

  @override
  State<DynamicLessonScreen> createState() => _DynamicLessonScreenState();
}

class _DynamicLessonScreenState extends State<DynamicLessonScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late TopicLessonService _topicLessonService;
  
  int _currentStep = 0;
  Map<int, List<int>> _selectedAnswers = {}; // Para tipo 1
  Map<int, List<int>> _orderedAnswers = {}; // Para tipo 2
  Map<int, int> _exerciseErrors = {}; // Contar errores por ejercicio
  Map<int, DateTime> _exerciseStartTimes = {}; // Tiempo de inicio por ejercicio
  Map<int, bool> _exerciseSubmitted = {}; // Si ya se envió al backend
  bool _isCompleting = false;
  bool _showingFeedback = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _initializeService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeService() async {
    final client = await GraphQLService.getClient();
    _topicLessonService = TopicLessonService(client);
  }

  int get _totalSteps {
    // Paso de contenido + ejercicios
    return (widget.lesson.content != null ? 1 : 0) + widget.lesson.exercises.length;
  }

  // MÉTODOS DE NAVEGACIÓN
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Si entramos a un ejercicio, marcar el tiempo de inicio
      _markExerciseStartTime();
    } else {
      _completeLesson();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // MÉTODOS DE EJERCICIOS
  void _markExerciseStartTime() {
    final exerciseIndex = widget.lesson.content != null ? _currentStep - 1 : _currentStep;
    
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      final exercise = widget.lesson.exercises[exerciseIndex];
      if (!_exerciseStartTimes.containsKey(exercise.id)) {
        _exerciseStartTimes[exercise.id] = DateTime.now();
        _exerciseErrors[exercise.id] = 0; // Inicializar errores
        
        // Para ejercicios de tipo 2, inicializar con opciones mezcladas
        if (exercise.type == 2 && !_orderedAnswers.containsKey(exercise.id)) {
          _orderedAnswers[exercise.id] = [];
        }
      }
    }
  }

  bool _canGoNext() {
    // Si estamos en el contenido, siempre se puede avanzar
    if (widget.lesson.content != null && _currentStep == 0) {
      return true;
    }

    // Si estamos en un ejercicio, verificar si tiene respuestas (no necesariamente correctas)
    final exerciseIndex = widget.lesson.content != null ? _currentStep - 1 : _currentStep;
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      final exercise = widget.lesson.exercises[exerciseIndex];
      
      if (exercise.type == 1) {
        // Tipo 1: debe tener al menos una respuesta seleccionada
        final selected = _selectedAnswers[exercise.id] ?? [];
        return selected.isNotEmpty;
      } else if (exercise.type == 2) {
        // Tipo 2: debe tener todas las opciones ordenadas
        final ordered = _orderedAnswers[exercise.id] ?? [];
        return ordered.length == exercise.options.length;
      }
    }

    return false;
  }

  bool _isExerciseCorrect(Exercise exercise) {
    if (exercise.type == 1) {
      // Verificar respuestas de selección múltiple
      final selected = _selectedAnswers[exercise.id] ?? [];
      final correctOptions = exercise.options.where((opt) => opt.isCorrect).map((opt) => opt.id).toList();
      
      if (selected.length != correctOptions.length) return false;
      
      for (final correctId in correctOptions) {
        if (!selected.contains(correctId)) return false;
      }
      return true;
    } else if (exercise.type == 2) {
      // Verificar orden correcto
      final ordered = _orderedAnswers[exercise.id] ?? [];
      final correctOrder = exercise.options.toList()..sort((a, b) => a.index.compareTo(b.index));
      
      if (ordered.length != correctOrder.length) return false;
      
      for (int i = 0; i < ordered.length; i++) {
        if (ordered[i] != correctOrder[i].id) return false;
      }
      return true;
    }
    return false;
  }

  // VALIDACIÓN Y ENVÍO AL BACKEND
  Future<void> _validateAndSubmitExercise() async {
    final exerciseIndex = widget.lesson.content != null ? _currentStep - 1 : _currentStep;
    
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      final exercise = widget.lesson.exercises[exerciseIndex];
      final isCorrect = _isExerciseCorrect(exercise);
      
      if (!isCorrect) {
        // Incrementar errores
        _exerciseErrors[exercise.id] = (_exerciseErrors[exercise.id] ?? 0) + 1;
        
        // Mostrar feedback de error
        _showErrorFeedback(exercise);
        return;
      }
      
      // Si es correcto y no se ha enviado antes, enviar al backend
      if (!(_exerciseSubmitted[exercise.id] ?? false)) {
        await _submitExerciseToBackend(exercise);
      }
      
      // Mostrar feedback de éxito
      _showSuccessFeedback(exercise);
    }
  }

  Future<void> _submitExerciseToBackend(Exercise exercise) async {
    try {
      final startTime = _exerciseStartTimes[exercise.id] ?? DateTime.now();
      final endTime = DateTime.now();
      final errors = _exerciseErrors[exercise.id] ?? 0;
      
      await _topicLessonService.submitExerciseResult(
        exerciseId: exercise.id,
        startedAt: startTime,
        finishedAt: endTime,
        errors: errors,
      );
      
      // Marcar como enviado
      _exerciseSubmitted[exercise.id] = true;
      
      print('Ejercicio ${exercise.id} enviado al backend con $errors errores');
    } catch (e) {
      print('Error enviando ejercicio al backend: $e');
      // No interrumpimos el flujo si falla el envío
    }
  }

  // FEEDBACK VISUAL
  void _showErrorFeedback(Exercise exercise) {
    setState(() {
      _showingFeedback = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Respuesta incorrecta. ¡Inténtalo de nuevo!',
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Resetear respuestas para que el usuario intente de nuevo
    _resetExerciseAnswers(exercise);
    
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showingFeedback = false;
        });
      }
    });
  }

  void _showSuccessFeedback(Exercise exercise) {
    setState(() {
      _showingFeedback = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '¡Correcto! +${exercise.coins} monedas',
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showingFeedback = false;
        });
      }
    });
  }

  void _showIncompleteMessage() {
    final exercise = _getCurrentExercise();
    if (exercise == null) return;
    
    String message;
    if (exercise.type == 1) {
      message = 'Por favor selecciona al menos una respuesta antes de continuar.';
    } else {
      message = 'Por favor ordena todas las opciones antes de continuar.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetExerciseAnswers(Exercise exercise) {
    setState(() {
      if (exercise.type == 1) {
        _selectedAnswers[exercise.id] = [];
      } else if (exercise.type == 2) {
        _orderedAnswers[exercise.id] = [];
      }
    });
  }

  // COMPLETAR LECCIÓN
  Future<void> _completeLesson() async {
    if (_isCompleting) return;
    
    setState(() {
      _isCompleting = true;
    });

    try {
      // Calcular puntaje total
      int totalCoins = 0;
      for (final exercise in widget.lesson.exercises) {
        if (_isExerciseCorrect(exercise)) {
          totalCoins += exercise.coins;
        }
      }

      // Agregar recompensas
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      
      await studentProvider.completeLesson(
        widget.lesson.id.toString(),
        context: context,
      );
      
      if (totalCoins > 0) {
        await coinProvider.addCoins(
          totalCoins,
          reason: 'Ejercicios completados',
        );
      }

      // Llamar callback de completado
      widget.onComplete();

      // Navegar de vuelta
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error completando lección: $e');
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  // HELPERS DE UI
  bool _isOnExerciseStep() {
    if (widget.lesson.content != null && _currentStep == 0) {
      return false; // Estamos en el contenido
    }
    return true; // Estamos en un ejercicio
  }

  Exercise? _getCurrentExercise() {
    final exerciseIndex = widget.lesson.content != null ? _currentStep - 1 : _currentStep;
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      return widget.lesson.exercises[exerciseIndex];
    }
    return null;
  }

  IconData _getNextButtonIcon() {
    if (_isCompleting) return Icons.hourglass_empty;
    if (_currentStep == _totalSteps - 1) return Icons.check;
    if (_isOnExerciseStep() && !_canGoNext()) return Icons.quiz;
    return Icons.arrow_forward;
  }

  String _getNextButtonText() {
    if (_isCompleting) return 'Completando...';
    if (_currentStep == _totalSteps - 1) return 'Completar';
    if (_isOnExerciseStep() && !_canGoNext()) return 'Verificar';
    return 'Siguiente';
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  // BUILD METHODS
  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: widget.lesson.title,
      showBackButton: true,
      body: Column(
        children: [
          // Barra de progreso
          _buildProgressBar(),
          
          // Contenido principal
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalSteps,
              itemBuilder: (context, index) {
                return _buildStepContent(index);
              },
            ),
          ),
          
          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalSteps > 0 ? (_currentStep + 1) / _totalSteps : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso ${_currentStep + 1} de $_totalSteps',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int stepIndex) {
    // Si hay contenido y estamos en el primer paso
    if (widget.lesson.content != null && stepIndex == 0) {
      return _buildContentStep();
    }
    
    // Calcular índice del ejercicio
    final exerciseIndex = widget.lesson.content != null ? stepIndex - 1 : stepIndex;
    
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      final exercise = widget.lesson.exercises[exerciseIndex];
      
      // Marcar tiempo de inicio si es la primera vez que ve este ejercicio
      if (!_exerciseStartTimes.containsKey(exercise.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markExerciseStartTime();
        });
      }
      
      return _buildExerciseStep(exercise);
    }
    
    return Container();
  }

  Widget _buildContentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen si existe
          if (widget.lesson.imgLink != null) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.lesson.imgLink!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Contenido de texto
          if (widget.lesson.content != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                widget.lesson.content!,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseStep(Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pregunta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pregunta',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(exercise.severity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.severity.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.question,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Opciones según el tipo
          if (exercise.type == 1)
            _buildMultipleChoiceOptions(exercise)
          else if (exercise.type == 2)
            _buildOrderingOptions(exercise),
            
          // Espacio extra al final para evitar desbordamiento
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(Exercise exercise) {
    final selected = _selectedAnswers[exercise.id] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la(s) respuesta(s) correcta(s):',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...exercise.options.map((option) {
          final isSelected = selected.contains(option.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: BounceAnimation(
              child: GestureDetector(
                onTap: _showingFeedback ? null : () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(option.id);
                    } else {
                      selected.add(option.id);
                    }
                    _selectedAnswers[exercise.id] = selected;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 14,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderingOptions(Exercise exercise) {
    final ordered = _orderedAnswers[exercise.id] ?? [];
    
    // Crear lista de opciones disponibles mezcladas solo una vez
    List<ExerciseOption> shuffledOptions = [];
    if (!_exerciseStartTimes.containsKey(exercise.id)) {
      // Primera vez: mezclar opciones
      shuffledOptions = List<ExerciseOption>.from(exercise.options)..shuffle();
    } else {
      // Ya se mezclaron: obtener opciones no ordenadas manteniendo el orden mezclado original
      final allShuffled = List<ExerciseOption>.from(exercise.options)..shuffle();
      shuffledOptions = allShuffled.where((opt) => !ordered.contains(opt.id)).toList();
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // Máximo 60% de la pantalla
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ordena las opciones de menor a mayor:',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Área de ordenamiento - Altura fija
          Container(
            height: 120, // Altura fija para evitar desbordamiento
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu orden:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ordered.isEmpty
                      ? Center(
                          child: Text(
                            'Toca las opciones de abajo\npara ordenarlas aquí',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: ordered.asMap().entries.map((entry) {
                              final index = entry.key;
                              final optionId = entry.value;
                              final option = exercise.options.firstWhere((opt) => opt.id == optionId);
                              return _buildOrderedOption(option, exercise.id, index);
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opciones disponibles
          Text(
            'Opciones disponibles:',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Lista de opciones con altura limitada
          if (shuffledOptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todas las opciones han sido colocadas. Presiona "Verificar" para comprobar tu respuesta.',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: 150, // Altura máxima para las opciones
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shuffledOptions.map((option) {
                    return _buildDraggableOption(option, exercise.id);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderedOption(ExerciseOption option, int exerciseId, int position) {
    return BounceAnimation(
      child: GestureDetector(
        onTap: _showingFeedback ? null : () {
          setState(() {
            final ordered = _orderedAnswers[exerciseId] ?? [];
            ordered.removeAt(position);
            _orderedAnswers[exerciseId] = ordered;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${position + 1}',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableOption(ExerciseOption option, int exerciseId) {
    return BounceAnimation(
      child: GestureDetector(
        onTap: _showingFeedback ? null : () {
          setState(() {
            final ordered = _orderedAnswers[exerciseId] ?? [];
            ordered.add(option.id);
            _orderedAnswers[exerciseId] = ordered;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            option.text,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón anterior
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showingFeedback ? null : _previousStep,
                icon: Icon(Icons.arrow_back),
                label: Text(
                  'Anterior',
                  style: TextStyle(fontFamily: 'Comic Sans MS'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          // Botón siguiente/completar/verificar
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: _showingFeedback || _isCompleting
                  ? null
                  : () async {
                      if (_isOnExerciseStep()) {
                        // Si estamos en un ejercicio, primero verificar si tiene respuestas
                        if (!_canGoNext()) {
                          // No tiene respuestas, mostrar mensaje
                          _showIncompleteMessage();
                          return;
                        }
                        
                        // Tiene respuestas, validar si son correctas
                        await _validateAndSubmitExercise();
                        
                        // Si es correcto, avanzar automáticamente después del feedback
                        if (_isExerciseCorrect(_getCurrentExercise()!)) {
                          Future.delayed(Duration(seconds: 2), () {
                            if (mounted && !_showingFeedback) {
                              if (_currentStep == _totalSteps - 1) {
                                _completeLesson();
                              } else {
                                _nextStep();
                              }
                            }
                          });
                        }
                      } else {
                        // Si no es ejercicio, avanzar directamente
                        if (_currentStep == _totalSteps - 1) {
                          _completeLesson();
                        } else {
                          _nextStep();
                        }
                      }
                    },
              icon: _isCompleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_getNextButtonIcon()),
              label: Text(
                _getNextButtonText(),
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_canGoNext() || !_isOnExerciseStep()) && !_showingFeedback 
                    ? AppColors.primary 
                    : Colors.grey.shade300,
                foregroundColor: (_canGoNext() || !_isOnExerciseStep()) && !_showingFeedback 
                    ? Colors.white 
                    : Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}