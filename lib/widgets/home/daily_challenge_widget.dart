// lib/widgets/home/daily_challenge_widget.dart (corregida)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/reward_service.dart';
import '../animations/bounce_animation.dart';
import '../common/app_card.dart';
import '../common/option_button.dart';

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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeState();
  }

  // Cargar el estado del desafío desde SharedPreferences
  Future<void> _loadChallengeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      final isCompleted = prefs.getBool('daily_challenge_$dateKey') ?? false;
      
      if (mounted) {
        setState(() {
          _isCompleted = isCompleted;
        });
      }
    } catch (e) {
      print('Error loading challenge state: $e');
    }
  }

  // Guardar el estado del desafío
  Future<void> _saveChallengeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      await prefs.setBool('daily_challenge_$dateKey', true);
    } catch (e) {
      print('Error saving challenge state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BounceAnimation(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AppCard(
          borderColor: AppColors.secondary.withOpacity(0.5),
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          child: Column(
            children: [
              _buildHeader(),
              if (_isExpanded)
                _buildExpandedContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final textColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : AppColors.textPrimary;
    
    return Padding(
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
          
          // Información del desafío - Usando Flexible para evitar overflow
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila con el título y badge - Usando Wrap para responsive
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+50 XP +25 monedas',
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
                  _isCompleted ? '¡Desafío Completado!' : 'Resuelve el problema matemático',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCompleted ? AppColors.success : textColor,
                  ),
                ),
                if (!_isExpanded && !_isCompleted)
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: AppColors.secondary.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Toca para ver el desafío',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Flecha para expandir/contraer
          if (!_isCompleted)
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.secondary,
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.celebration,
              color: AppColors.success,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              '¡Desafío completado con éxito!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve mañana para un nuevo desafío',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                color: AppColors.success.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    
    return AnimatedContainer(
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
          
          // Opciones de respuesta - Corregido el overflow usando Column para pantallas pequeñas
          LayoutBuilder(
            builder: (context, constraints) {
              // Si el ancho es menor a 400px, usar columna en lugar de fila
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildAnswerOption(0, '8', false)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildAnswerOption(1, '13', false)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildAnswerOption(2, '18', true)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildAnswerOption(3, '22', false)),
                      ],
                    ),
                  ],
                );
              } else {
                // Layout original para pantallas más grandes
                return Row(
                  children: [
                    Expanded(child: _buildAnswerOption(0, '8', false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerOption(1, '13', false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerOption(2, '18', true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerOption(3, '22', false)),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Botón para completar el desafío
          Center(
            child: ElevatedButton(
              onPressed: (_selectedAnswerIndex != null && !_isProcessing) 
                  ? _completeChallenge 
                  : null,
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
              child: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Comprobar respuesta',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pista del desafío
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
    );
  }

  Widget _buildAnswerOption(int index, String answer, bool isCorrect) {
    final bool isSelected = _selectedAnswerIndex == index;
    
    return OptionButton(
      text: answer,
      isCorrect: isCorrect,
      onSelected: _isCompleted ? null : () {
        setState(() {
          _selectedAnswerIndex = index;
        });
      },
      width: double.infinity,
      height: 50,
      color: AppColors.secondary,
    );
  }

  Future<void> _completeChallenge() async {
    if (_selectedAnswerIndex == null || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    // Verificar si la respuesta es correcta (índice 2 = "18")
    final isCorrect = _selectedAnswerIndex == 2;
    
    if (isCorrect) {
      try {
        // Usar el RewardService para otorgar recompensas
        await RewardService.completeChallenge(
          context: context,
          xpEarned: 50,
          coinsEarned: 25,
        );
        
        // Guardar el estado del desafío como completado
        await _saveChallengeState();
        
        setState(() {
          _isCompleted = true;
          _isProcessing = false;
        });
        
        widget.onComplete();
        
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar desafío: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Respuesta incorrecta! Inténtalo de nuevo.',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}