// lib/screens/teacher/teacher_students_content.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_card.dart';

class TeacherStudentsContent extends StatelessWidget {
  const TeacherStudentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar personalizada
          _buildAppBar(),
          
          // Contenido (por ahora placeholder)
          Expanded(
            child: _buildPlaceholderContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.7),
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
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Estudiantes',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.school,
                  size: 80,
                  color: AppColors.secondary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gestión de Estudiantes',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Esta función estará disponible próximamente.\n\nAquí podrás:\n• Ver todos tus estudiantes\n• Revisar su progreso\n• Asignar tareas\n• Monitorear actividad',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '🚀 Próximamente',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100), // Espacio para el bottom navigation
        ],
      ),
    );
  }
}