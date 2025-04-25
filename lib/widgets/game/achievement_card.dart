// lib/widgets/game/achievement_card.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';

class AchievementCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int pointsValue;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.pointsValue,
    this.onTap,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  late ConfettiController _confettiController;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Si el logro está desbloqueado, mostrar confeti al cargar
    if (widget.unlocked && !_hasPlayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
        _hasPlayed = true;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    
    final borderColor = widget.unlocked 
        ? AppColors.star 
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);
    
    final backgroundColor = widget.unlocked 
        ? AppColors.star.withOpacity(0.1) 
        : (isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade100);
    
    return Stack(
      children: [
        // Tarjeta de logro
        GestureDetector(
          onTap: widget.onTap,
          child: BounceAnimation(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.unlocked
                        ? AppColors.star.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icono del logro
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.unlocked ? AppColors.star : Colors.grey,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Contenido textual
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Estado del logro
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.unlocked
                                      ? AppColors.star
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.unlocked ? '¡DESBLOQUEADO!' : 'BLOQUEADO',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Título del logro
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.unlocked
                                      ? AppColors.star
                                      : (isDarkMode ? Colors.grey : Colors.grey.shade600),
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Descripción del logro
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 14,
                                  color: widget.unlocked
                                      ? textColor
                                      : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500),
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Valor en puntos
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: widget.unlocked
                                        ? AppColors.star
                                        : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${widget.pointsValue} puntos',
                                    style: TextStyle(
                                      fontFamily: 'Comic Sans MS',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: widget.unlocked
                                          ? AppColors.star
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Controlador de confeti para cuando se desbloquea un logro
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.yellow,
              Colors.green,
              Colors.purple,
              Colors.orange,
            ],
          ),
        ),
        
        // Insignia de "NUEVO" si aplica
        if (widget.unlocked && !_hasPlayed)
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '¡NUEVO!',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}