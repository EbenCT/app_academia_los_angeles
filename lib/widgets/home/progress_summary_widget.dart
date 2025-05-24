import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../common/app_card.dart';
import '../common/stat_card.dart';

class ProgressSummaryWidget extends StatelessWidget {
  final int points;
  final int level;
  final int streakDays;
  final int nextLevelPoints; // Puntos para el siguiente nivel
  final int lessonsCompleted; // Mantenemos por compatibilidad pero no lo usamos
  final int totalLessons; // Mantenemos por compatibilidad pero no lo usamos

  const ProgressSummaryWidget({
    super.key,
    required this.points,
    required this.level,
    required this.streakDays,
    this.nextLevelPoints = 100, // Por defecto, 100 puntos
    this.lessonsCompleted = 0,
    this.totalLessons = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Calcular porcentaje de progreso hacia el siguiente nivel
    final nextLevelTarget = level * nextLevelPoints;
    final progressPercentage = points / nextLevelTarget;
    // La barra no debe exceder el 100%
    final normalizedProgress = progressPercentage > 1.0 ? 1.0 : progressPercentage;
    // Formato del porcentaje para mostrar
    final progressText = '${(progressPercentage * 100).toInt()}%';
    // Puntos restantes para el siguiente nivel
    final pointsRemaining = nextLevelTarget - points > 0 ? nextLevelTarget - points : 0;

    return AppCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: StatCard.progressItem(
                    title: 'Puntos',
                    value: '$points',
                    icon: Icons.star,
                    color: AppColors.star,
                  ),
                ),
                Flexible(
                  child: StatCard.progressItem(
                    title: 'Nivel',
                    value: '$level',
                    icon: Icons.rocket_launch,
                    color: AppColors.primary,
                  ),
                ),
                Flexible(
                  child: StatCard.progressItem(
                    title: 'Racha',
                    value: '$streakDays días',
                    icon: Icons.local_fire_department,
                    color: AppColors.secondary,
                  ),
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
                    Flexible(
                      child: Text(
                        'Progreso al siguiente nivel',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      progressText,
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
                _buildProgressBar(normalizedProgress),
                const SizedBox(height: 8),
                Text(
                  pointsRemaining > 0 
                      ? '¡Necesitas $pointsRemaining puntos más para el nivel ${level + 1}!'
                      : '¡Estás listo para el siguiente nivel!',
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

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
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
                    AppColors.primary.withOpacity(0.7),
                    AppColors.primary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          
          // Estrellas decorativas que se muestran según el progreso
          if (progress > 0.2) _buildProgressStar(20),
          if (progress > 0.5) _buildProgressStar(50),
          if (progress > 0.8) _buildProgressStar(80),
        ],
      ),
    );
  }
  
  Widget _buildProgressStar(double position) {
    return Positioned(
      left: position,
      top: 3,
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}