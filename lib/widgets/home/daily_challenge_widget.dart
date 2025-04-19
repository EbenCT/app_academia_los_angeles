// lib/widgets/home/daily_challenge_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../animations/bounce_animation.dart';

class DailyChallengeWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const DailyChallengeWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<DailyChallengeWidget> createState() => _DailyChallengeWidgetState();
}

class _DailyChallengeWidgetState extends State<DailyChallengeWidget> {
  bool _isExpanded = false;
  bool _isCompleted = false;
  int? _selectedAnswerIndex;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    
    return BounceAnimation(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icono de desafío
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: _isCompleted 
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 36,
                          )
                        : Icon(
                            Icons.emoji_events,
                            color: AppColors.secondary,
                            size: 36,
                          ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Información del desafío
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'DESAFÍO DEL DÍA',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+50 pts',
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
                          const SizedBox(height: 4),
                          Text(
                            'Resuelve el problema matemático',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (!_isExpanded)
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: AppColors.secondary.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Toca para ver el desafío',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // Flecha para expandir/contraer
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              
              // Contenido expandible
              if (_isExpanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? AppColors.darkBackground.withOpacity(0.3) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '¿Cuánto es 24 ÷ 3 + 5 × 2?',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Opciones de respuesta
                      Row(
                        children: [
                          _buildAnswerOption(0, '8', false),
                          const SizedBox(width: 10),
                          _buildAnswerOption(1, '13', false),
                          const SizedBox(width: 10),
                          _buildAnswerOption(2, '18', true),
                          const SizedBox(width: 10),
                          _buildAnswerOption(3, '22', false),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botón para completar el desafío
                      if (!_isCompleted)
                        Center(
                          child: ElevatedButton(
                            onPressed: _selectedAnswerIndex != null ? () {
                              setState(() {
                                _isCompleted = true;
                              });
                              widget.onComplete();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.secondary.withOpacity(0.3),
                              disabledForegroundColor: Colors.white60,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Comprobar respuesta',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                      if (_isCompleted)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '¡Correcto! +50 puntos',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Pista del desafío
                      if (!_isCompleted)
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pista: Recuerda el orden de las operaciones - primero divisiones y multiplicaciones, luego sumas y restas.',
                                    style: TextStyle(fontFamily: 'Comic Sans MS'),
                                  ),
                                  backgroundColor: AppColors.info,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                            label: Text(
                              '¿Necesitas una pista?',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnswerOption(int index, String answer, bool isCorrect) {
    final bool isSelected = _selectedAnswerIndex == index;
    final bool showCorrectAnswer = _isCompleted && isCorrect;
    
    return Expanded(
      child: GestureDetector(
        onTap: _isCompleted ? null : () {
          setState(() {
            _selectedAnswerIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: showCorrectAnswer
                ? AppColors.success.withOpacity(0.2)
                : isSelected
                    ? AppColors.secondary.withOpacity(0.2)
                    : AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showCorrectAnswer
                  ? AppColors.success
                  : isSelected
                      ? AppColors.secondary
                      : AppColors.secondary.withOpacity(0.5),
              width: isSelected || showCorrectAnswer ? 2 : 1,
            ),
            boxShadow: isSelected || showCorrectAnswer
                ? [
                    BoxShadow(
                      color: (showCorrectAnswer ? AppColors.success : AppColors.secondary).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                answer,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: showCorrectAnswer
                      ? AppColors.success
                      : isSelected
                          ? AppColors.secondary
                          : AppColors.secondary.withOpacity(0.7),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                ),
              if (showCorrectAnswer)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}