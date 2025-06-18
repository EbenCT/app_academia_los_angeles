// lib/screens/game/generic_lesson_screen.dart

import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../services/lesson_api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/lessons/generic_exercise_widget.dart';
import '../../widgets/screens/screen_base.dart';

class GenericLessonScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final VoidCallback? onLessonCompleted;

  const GenericLessonScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.onLessonCompleted,
  });

  @override
  State<GenericLessonScreen> createState() => _GenericLessonScreenState();
}

class _GenericLessonScreenState extends State<GenericLessonScreen> {
  Lesson? _lesson;
  bool _isLoading = true;
  String? _errorMessage;
  
  int _currentStep = 0; // 0 = contenido, 1+ = ejercicios
  bool _isCompleting = false;
  
  int _currentStudentId = 1; // TODO: Obtener del usuario logueado
  List<bool> _exerciseResults = [];

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lesson = await LessonApiService.getLessonWithExercises(widget.lessonId);
      
      setState(() {
        _lesson = lesson;
        _exerciseResults = List.filled(lesson.exercises.length, false);
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_lesson == null) return;

    setState(() {
      if (_currentStep < _lesson!.exercises.length) {
        _currentStep++;
      } else {
        _completeLesson();
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _onExerciseCompleted(int exerciseIndex, bool wasCorrect) {
    setState(() {
      _exerciseResults[exerciseIndex] = wasCorrect;
    });

    // Guardar progreso del ejercicio en el backend
    _saveExerciseProgress(exerciseIndex, wasCorrect);
  }

  Future<void> _saveExerciseProgress(int exerciseIndex, bool wasCorrect) async {
    if (_lesson == null || exerciseIndex >= _lesson!.exercises.length) return;

    final exercise = _lesson!.exercises[exerciseIndex];
    
    try {
      final progress = StudentExerciseProgress(
        id: 0, // El backend asignará el ID
        studentId: _currentStudentId,
        exerciseId: exercise.id,
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
        error: !wasCorrect,
      );

      await LessonApiService.saveExerciseProgress(progress);
    } catch (e) {
      print('Error guardando progreso del ejercicio: $e');
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      // Aquí podrías enviar al backend que la lección fue completada
      await Future.delayed(Duration(seconds: 1)); // Simular procesamiento

      // Llamar callback de completado
      widget.onLessonCompleted?.call();

      // Volver a la pantalla anterior
      if (mounted) {
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      setState(() {
        _isCompleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar lección: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: widget.lessonTitle,
      showBackButton: true,
      isLoading: _isCompleting,
      loadingMessage: 'Completando lección...',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: LoadingIndicator(
          message: 'Cargando lección...',
          useAstronaut: true,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_lesson == null) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Indicador de progreso
        _buildProgressIndicator(),
        
        // Contenido principal
        Expanded(
          child: _buildStepContent(),
        ),
        
        // Botones de navegación
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar la lección',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadLesson,
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Text(
        'No se pudo cargar el contenido de la lección',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (_lesson == null) return SizedBox();

    final totalSteps = _lesson!.exercises.length + 1; // +1 por el contenido inicial
    final progress = (_currentStep + 1) / totalSteps;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso ${_currentStep + 1} de $totalSteps',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_lesson == null) return SizedBox();

    if (_currentStep == 0) {
      // Mostrar contenido de la lección
      return _buildLessonContent();
    } else {
      // Mostrar ejercicio
      final exerciseIndex = _currentStep - 1;
      if (exerciseIndex < _lesson!.exercises.length) {
        return _buildExerciseContent(exerciseIndex);
      }
    }

    return SizedBox();
  }

  Widget _buildLessonContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FadeAnimation(
        delay: Duration(milliseconds: 300),
        child: Column(
          children: [
            // Título de la lección
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _lesson!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Contenido de la lección
            if (_lesson!.content != null && _lesson!.content!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _lesson!.content!,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Imagen si existe
            if (_lesson!.imgLink != null && _lesson!.imgLink!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _lesson!.imgLink!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            SizedBox(height: 30),
            
            // Información sobre ejercicios
            if (_lesson!.exercises.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      color: AppColors.info,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A continuación practicarás con ${_lesson!.exercises.length} ejercicio${_lesson!.exercises.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent(int exerciseIndex) {
    final exercise = _lesson!.exercises[exerciseIndex];
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: FadeAnimation(
        delay: Duration(milliseconds: 300),
        child: GenericExerciseWidget(
          exercise: exercise,
          onCompleted: (wasCorrect) => _onExerciseCompleted(exerciseIndex, wasCorrect),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_lesson == null) return SizedBox();

    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep >= _lesson!.exercises.length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón anterior
          if (!isFirstStep)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _previousStep,
                icon: Icon(Icons.arrow_back),
                label: Text('Anterior'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          
          if (!isFirstStep) SizedBox(width: 16),
          
          // Botón siguiente/completar
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _nextStep,
              icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
              label: Text(isLastStep ? '¡Completar!' : 'Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}