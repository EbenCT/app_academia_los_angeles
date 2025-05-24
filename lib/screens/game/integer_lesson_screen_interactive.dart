// lib/screens/game/integer_lesson_screen_interactive.dart (actualizada)
import 'package:flutter/material.dart';
import '../../services/reward_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/screens/screen_base.dart';
import '../../widgets/common/custom_button.dart';
import '../game/integer_lesson_steps_interactive.dart';

class IntegerLessonScreenInteractive extends StatefulWidget {
  const IntegerLessonScreenInteractive({super.key});

  @override
  State<IntegerLessonScreenInteractive> createState() => _IntegerLessonScreenInteractiveState();
}

class _IntegerLessonScreenInteractiveState extends State<IntegerLessonScreenInteractive> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isCompleted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  Future<void> _completeLesson() async {
    if (_isCompleted) return;
    
    setState(() {
      _isCompleted = true;
    });

    try {
      // Usar el RewardService para otorgar recompensas
      await RewardService.completeLesson(
        context: context,
        lessonId: 'integer_lesson_01',
        customXp: 100, // XP personalizado para esta lección
        customCoins: 50, // Monedas personalizadas
      );

      // Navegar de vuelta y marcar como completada
      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para indicar completado
      }
    } catch (e) {
      setState(() {
        _isCompleted = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar progreso: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: 'Números Enteros',
      showBackButton: true,
      isLoading: _isCompleted,
      loadingMessage: 'Guardando tu progreso...',
      body: Column(
        children: [
          // Indicador de progreso
          _buildProgressIndicator(),
          
          // Contenido de pasos
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                WhatAreIntegersStepInteractive(),
                NumberLineStepInteractive(),
                ApplicationsStepInteractive(),
              ],
            ),
          ),
          
          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progreso: ${_currentStep + 1} de $_totalSteps',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Spacer(),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Anterior',
                onPressed: _previousStep,
                isOutlined: true,
                icon: Icons.arrow_back,
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            child: CustomButton(
              text: _currentStep == _totalSteps - 1 ? '¡Completar!' : 'Siguiente',
              onPressed: _nextStep,
              icon: _currentStep == _totalSteps - 1 
                  ? Icons.check_circle 
                  : Icons.arrow_forward,
              backgroundColor: _currentStep == _totalSteps - 1 
                  ? AppColors.success 
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}