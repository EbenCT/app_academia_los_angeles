// lib/widgets/home/progress_summary_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../animations/bounce_animation.dart';

class ProgressSummaryWidget extends StatelessWidget {
  final int points;
  final int level;
  final int streakDays;

  const ProgressSummaryWidget({
    super.key,
    required this.points,
    required this.level,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressCard(
                  context: context,
                  title: 'Puntos',
                  value: '$points',
                  icon: Icons.star,
                  color: AppColors.star,
                ),
                _buildProgressCard(
                  context: context,
                  title: 'Nivel',
                  value: '$level',
                  icon: Icons.rocket_launch,
                  color: AppColors.primary,
                ),
                _buildProgressCard(
                  context: context,
                  title: 'Racha',
                  value: '$streakDays días',
                  icon: Icons.local_fire_department,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          
          // Barra de progreso de nivel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso al siguiente nivel',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      '${60}%',
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
                _buildFancyProgressBar(
                  progress: 0.6,
                  color: AppColors.primary,
                ),
                
                const SizedBox(height: 8),
                Text(
                  '¡Necesitas 400 puntos más para el nivel ${level + 1}!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BounceAnimation(
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyProgressBar({
    required double progress,
    required Color color,
  }) {
    return Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Barra de progreso
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.7),
                    color,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          
          // Estrellas decorativas
          if (progress > 0.2)
            Positioned(
              left: 20,
              top: 3,
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 14,
              ),
            ),
          if (progress > 0.5)
            Positioned(
              left: 50,
              top: 3,
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 14,
              ),
            ),
          if (progress > 0.8)
            Positioned(
              left: 80,
              top: 3,
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}