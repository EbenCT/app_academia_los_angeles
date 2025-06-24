// lib/screens/courses/dynamic_lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/screens/screen_base.dart';
import '../../providers/student_provider.dart';
import '../../providers/coin_provider.dart';
import '../../services/topic_lesson_service.dart';
import '../../services/graphql_service.dart';
import '../../services/exercise_validator.dart';
import '../../widgets/lessons/error_explanation_widget.dart';
import '../../widgets/lessons/ai_help_dialog.dart';
import '../../widgets/lessons/exercise_widgets.dart';

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
  
  // Estado de navegación
  int _currentStep = 0;
  bool _isCompleting = false;
  bool _showingFeedback = false;
  bool _showingAIHelp = false;
  
  // Respuestas de ejercicios
  Map<int, List<int>> _selectedAnswers = {};
  Map<int, List<int>> _orderedAnswers = {};
  
  // Tracking de ejercicios
  Map<int, int> _exerciseErrors = {};
  Map<int, DateTime> _exerciseStartTimes = {};
  Map<int, bool> _exerciseSubmitted = {};

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
    return (widget.lesson.content != null ? 1 : 0) + widget.lesson.exercises.length;
  }

  bool get _isOnExerciseStep {
    if (widget.lesson.content != null && _currentStep == 0) return false;
    return true;
  }

  Exercise? get _currentExercise {
    final exerciseIndex = widget.lesson.content != null ? _currentStep - 1 : _currentStep;
    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      return widget.lesson.exercises[exerciseIndex];
    }
    return null;
  }

  // NAVEGACIÓN
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markExerciseStartTime();
    } else {
      _completeLesson();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canGoNext() {
    if (!_isOnExerciseStep) return true;

    final exercise = _currentExercise;
    if (exercise == null) return false;

    if (exercise.type == 1) {
      final selected = _selectedAnswers[exercise.id] ?? [];
      return selected.isNotEmpty;
    } else if (exercise.type == 2) {
      final ordered = _orderedAnswers[exercise.id] ?? [];
      return ordered.length == exercise.options.length;
    }
    return false;
  }

  // EJERCICIOS
  void _markExerciseStartTime() {
    final exercise = _currentExercise;
    if (exercise != null && !_exerciseStartTimes.containsKey(exercise.id)) {
      _exerciseStartTimes[exercise.id] = DateTime.now();
      _exerciseErrors[exercise.id] = 0;
      
      if (exercise.type == 2) {
        _orderedAnswers[exercise.id] = [];
      }
    }
  }

  Future<void> _validateAndSubmitExercise() async {
    final exercise = _currentExercise;
    if (exercise == null) return;

    final isCorrect = ExerciseValidator.isExerciseCorrect(
      exercise, 
      _selectedAnswers, 
      _orderedAnswers
    );

    if (!isCorrect) {
      _exerciseErrors[exercise.id] = (_exerciseErrors[exercise.id] ?? 0) + 1;
      _showErrorFeedback(exercise);
      return;
    }

    if (!(_exerciseSubmitted[exercise.id] ?? false)) {
      await _submitExerciseToBackend(exercise);
    }
    _showSuccessFeedback(exercise);
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

      _exerciseSubmitted[exercise.id] = true;
    } catch (e) {
      print('Error enviando ejercicio al backend: $e');
    }
  }

  // FEEDBACK
  void _showErrorFeedback(Exercise exercise) {
    setState(() => _showingFeedback = true);

    _showAIErrorExplanation(exercise);
    _resetExerciseAnswers(exercise);

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) setState(() => _showingFeedback = false);
    });
  }

  void _showAIErrorExplanation(Exercise exercise) {
    final userAnswer = ExerciseValidator.getUserAnswerText(exercise, _selectedAnswers, _orderedAnswers);
    final correctAnswer = ExerciseValidator.getCorrectAnswerText(exercise);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorExplanationWidget(
        concept: 'números enteros',
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        lessonContext: widget.lesson.title,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSuccessFeedback(Exercise exercise) {
    setState(() => _showingFeedback = true);

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
      if (mounted) setState(() => _showingFeedback = false);
    });
  }

  void _showIncompleteMessage() {
    final exercise = _currentExercise;
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

  void _showAIHelp() {
    final exercise = _currentExercise;
    if (exercise == null) return;

    setState(() => _showingAIHelp = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIHelpDialog(
        exercise: exercise,
        lessonTitle: widget.lesson.title,
        onDismiss: () {
          setState(() => _showingAIHelp = false);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // COMPLETAR LECCIÓN
  Future<void> _completeLesson() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      int totalCoins = 0;
      for (final exercise in widget.lesson.exercises) {
        if (ExerciseValidator.isExerciseCorrect(exercise, _selectedAnswers, _orderedAnswers)) {
          totalCoins += exercise.coins;
        }
      }

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

      widget.onComplete();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('Error completando lección: $e');
    } finally {
      setState(() => _isCompleting = false);
    }
  }

  // HANDLERS DE EVENTOS
  void _onMultipleChoiceOptionSelected(int exerciseId, int optionId, bool isSelected) {
    setState(() {
      final selected = _selectedAnswers[exerciseId] ?? [];
      if (isSelected) {
        selected.remove(optionId);
      } else {
        selected.add(optionId);
      }
      _selectedAnswers[exerciseId] = selected;
    });
  }

  void _onOrderingOptionAdded(int exerciseId, int optionId) {
    setState(() {
      final ordered = _orderedAnswers[exerciseId] ?? [];
      ordered.add(optionId);
      _orderedAnswers[exerciseId] = ordered;
    });
  }

  void _onOrderingOptionRemoved(int exerciseId, int position) {
    setState(() {
      final ordered = _orderedAnswers[exerciseId] ?? [];
      ordered.removeAt(position);
      _orderedAnswers[exerciseId] = ordered;
    });
  }

  // UI HELPERS
  String _getNextButtonText() {
    if (_isCompleting) return 'Completando...';
    if (_currentStep == _totalSteps - 1) return 'Completar';
    if (_isOnExerciseStep && !_canGoNext()) return 'Verificar';
    return 'Siguiente';
  }

  IconData _getNextButtonIcon() {
    if (_isCompleting) return Icons.hourglass_empty;
    if (_currentStep == _totalSteps - 1) return Icons.check;
    if (_isOnExerciseStep && !_canGoNext()) return Icons.quiz;
    return Icons.arrow_forward;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'easy': return AppColors.success;
      case 'medium': return AppColors.warning;
      case 'hard': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  // BUILD METHODS
  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: widget.lesson.title,
      showBackButton: true,
      body: Stack(
        children: [
          Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _totalSteps,
                      itemBuilder: (context, index) => _buildStepContent(index),
                    ),
                    if (_isOnExerciseStep)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: AppColors.info,
                          onPressed: _showingFeedback || _showingAIHelp ? null : _showAIHelp,
                          tooltip: "Pedir ayuda con IA",
                          child: Icon(Icons.help_outline, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
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
    if (widget.lesson.content != null && stepIndex == 0) {
      return _buildContentStep();
    }

    final exerciseIndex = widget.lesson.content != null ? stepIndex - 1 : stepIndex;

    if (exerciseIndex >= 0 && exerciseIndex < widget.lesson.exercises.length) {
      final exercise = widget.lesson.exercises[exerciseIndex];

      if (!_exerciseStartTimes.containsKey(exercise.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _markExerciseStartTime());
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
          _buildQuestionHeader(exercise),
          const SizedBox(height: 24),
          if (exercise.type == 1)
            ExerciseWidgets.buildMultipleChoiceOptions(
              exercise: exercise,
              selectedAnswers: _selectedAnswers,
              onOptionSelected: _onMultipleChoiceOptionSelected,
              isDisabled: _showingFeedback,
            )
          else if (exercise.type == 2)
            ExerciseWidgets.buildOrderingOptions(
              exercise: exercise,
              orderedAnswers: _orderedAnswers,
              onOptionAdded: _onOrderingOptionAdded,
              onOptionRemoved: _onOrderingOptionRemoved,
              isDisabled: _showingFeedback,
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(Exercise exercise) {
    return Container(
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
              Icon(Icons.help_outline, color: AppColors.primary, size: 20),
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
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showingFeedback ? null : _previousStep,
                icon: Icon(Icons.arrow_back),
                label: Text('Anterior', style: TextStyle(fontFamily: 'Comic Sans MS')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: _showingFeedback || _isCompleting
                  ? null
                  : () async {
                      if (_isOnExerciseStep) {
                        if (!_canGoNext()) {
                          _showIncompleteMessage();
                          return;
                        }

                        await _validateAndSubmitExercise();

                        final exercise = _currentExercise;
                        if (exercise != null && ExerciseValidator.isExerciseCorrect(exercise, _selectedAnswers, _orderedAnswers)) {
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
              label: Text(_getNextButtonText(), style: TextStyle(fontFamily: 'Comic Sans MS')),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_canGoNext() || !_isOnExerciseStep) && !_showingFeedback
                    ? AppColors.primary
                    : Colors.grey.shade300,
                foregroundColor: (_canGoNext() || !_isOnExerciseStep) && !_showingFeedback
                    ? Colors.white
                    : Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}