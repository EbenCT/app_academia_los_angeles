// lib/widgets/home/achievement_preview_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../animations/fade_animation.dart';

class AchievementPreviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final VoidCallback onSeeMoreTap;

  const AchievementPreviewWidget({
    super.key,
    required this.achievements,
    required this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

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
          // Lista de logros
          ...achievements.asMap().entries.map((entry) {
            final index = entry.key;
            final achievement = entry.value;
            final bool unlocked = achievement['unlocked'] as bool;
            
            return FadeAnimation(
              delay: Duration(milliseconds: 100 * index),
              child: _buildAchievementItem(
                context: context,
                title: achievement['title'] as String,
                description: achievement['description'] as String,
                icon: achievement['icon'] as IconData,
                unlocked: unlocked,
                isLast: index == achievements.length - 1,
              ),
            );
          }).toList(),
          
          // Botón "Ver más"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: onSeeMoreTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver todos los logros',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool unlocked,
    required bool isLast,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icono del logro
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: unlocked 
                      ? AppColors.star.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: unlocked ? AppColors.star : Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del logro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: unlocked ? AppColors.star : Colors.grey,
                            ),
                          ),
                        ),
                        if (unlocked)
                          Icon(
                            Icons.verified,
                            color: AppColors.star,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: unlocked 
                            ? textColor.withOpacity(0.8) 
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Separador
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode 
                  ? Colors.grey.withOpacity(0.2) 
                  : Colors.grey.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}