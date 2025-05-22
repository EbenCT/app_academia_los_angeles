// lib/screens/achievements/achievements_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/game/achievement_card.dart';

class AchievementsContent extends StatelessWidget {
  const AchievementsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    
    return SafeArea(
      child: Column(
        children: [
          // App Bar personalizada
          _buildAppBar(studentProvider),
          
          // Contenido
          Expanded(
            child: RefreshIndicator(
              color: AppColors.star,
              onRefresh: () => studentProvider.refreshStudentData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de progreso
                    FadeAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: _buildProgressSummary(studentProvider),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Lista de logros
                    FadeAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: _buildAchievementsList(),
                    ),
                    
                    const SizedBox(height: 100), // Espacio para el bottom navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(StudentProvider studentProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.star,
            AppColors.star.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Mis Logros',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          // Puntos totales
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${studentProvider.xp}',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(StudentProvider studentProvider) {
    final unlockedAchievements = _getUnlockedAchievements();
    final totalAchievements = _getAllAchievements().length;
    final completionPercentage = (unlockedAchievements.length / totalAchievements * 100).toInt();
    
    return AppCard(
      backgroundColor: AppColors.star.withOpacity(0.1),
      borderColor: AppColors.star.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.star.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: AppColors.star,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso de Logros',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.star,
                      ),
                    ),
                    Text(
                      '${unlockedAchievements.length} de $totalAchievements desbloqueados',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completionPercentage%',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: AppColors.star.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.star),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievements = _getAllAchievements();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Todos los Logros',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.star,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AchievementCard(
                title: achievement['title'],
                description: achievement['description'],
                icon: achievement['icon'],
                unlocked: achievement['unlocked'],
                pointsValue: achievement['pointsValue'],
                onTap: () {
                  _showAchievementDetails(context, achievement);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getAllAchievements() {
    return [
      {
        'title': 'Primer Paso',
        'description': 'Completa tu primera lección',
        'icon': Icons.school,
        'unlocked': true,
        'pointsValue': 50,
      },
      {
        'title': 'Explorador Espacial',
        'description': 'Visita todas las secciones de la app',
        'icon': Icons.explore,
        'unlocked': true,
        'pointsValue': 30,
      },
      {
        'title': 'Matemático Novato',
        'description': 'Resuelve 10 problemas de números enteros',
        'icon': Icons.calculate,
        'unlocked': false,
        'pointsValue': 100,
      },
      {
        'title': 'Rescatista Héroe',
        'description': 'Completa el juego de rescate de alturas',
        'icon': Icons.flight,
        'unlocked': false,
        'pointsValue': 150,
      },
      {
        'title': 'Consistencia',
        'description': 'Estudia 7 días seguidos',
        'icon': Icons.local_fire_department,
        'unlocked': false,
        'pointsValue': 200,
      },
      {
        'title': 'Maestro de Números',
        'description': 'Obtén 100% en 5 lecciones',
        'icon': Icons.star,
        'unlocked': false,
        'pointsValue': 300,
      },
      {
        'title': 'Nivel Superior',
        'description': 'Alcanza el nivel 5',
        'icon': Icons.rocket_launch,
        'unlocked': false,
        'pointsValue': 250,
      },
      {
        'title': 'Coleccionista',
        'description': 'Desbloquea 10 logros',
        'icon': Icons.collections,
        'unlocked': false,
        'pointsValue': 400,
      },
    ];
  }

  List<Map<String, dynamic>> _getUnlockedAchievements() {
    return _getAllAchievements().where((achievement) => achievement['unlocked']).toList();
  }

  void _showAchievementDetails(BuildContext context, Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: achievement['unlocked']
                    ? [AppColors.star.withOpacity(0.8), AppColors.star.withOpacity(0.6)]
                    : [Colors.grey.withOpacity(0.8), Colors.grey.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  achievement['icon'],
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    achievement['description'],
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${achievement['pointsValue']} puntos',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: achievement['unlocked'] ? AppColors.star : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}