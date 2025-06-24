// lib/widgets/teacher/student_list_widget.dart
import 'package:flutter/material.dart';
import '../../models/student_tracking_model.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';

class StudentListWidget extends StatelessWidget {
  final List<StudentTrackingModel> students;
  final StudentTrackingModel? selectedStudent;
  final Function(StudentTrackingModel) onStudentSelected;

  const StudentListWidget({
    super.key,
    required this.students,
    required this.selectedStudent,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        _buildListHeader(),
        const SizedBox(height: 16),
        
        // Lista de estudiantes
        ...students.asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          final isSelected = selectedStudent?.id == student.id;
          
          return FadeAnimation(
            delay: Duration(milliseconds: 100 * (index + 1)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildStudentItem(student, isSelected),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes en esta aula',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los estudiantes aparecerán aquí cuando se unan al aula',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    final totalStudents = students.length;
    final activeStudents = students.where((s) => s.estado == 'activo').length;
    final averageProgress = students.isEmpty ? 0 : 
        students.map((s) => s.avance).reduce((a, b) => a + b) / totalStudents;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHeaderStat('Total', '$totalStudents', AppColors.secondary, Icons.people),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildHeaderStat('Activos', '$activeStudents', AppColors.success, Icons.check_circle),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildHeaderStat('Progreso', '${averageProgress.round()}%', AppColors.primary, Icons.trending_up),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentItem(StudentTrackingModel student, bool isSelected) {
    return InkWell(
      onTap: () => onStudentSelected(student),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: _getStatusColor(student.estado),
              child: Text(
                student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'E',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Información del estudiante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nivel ${student.nivelActual} • ${student.ultimaActividad}',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Métricas rápidas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressColor(student.avance).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${student.avance}%',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(student.avance),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(student.estado),
                      size: 12,
                      color: _getStatusColor(student.estado),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(student.estado),
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(student.estado),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Icono de selección
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'activo':
        return AppColors.success;
      case 'en_progreso':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'activo':
        return Icons.check_circle;
      case 'en_progreso':
        return Icons.schedule;
      default:
        return Icons.pause_circle;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'activo':
        return 'Activo';
      case 'en_progreso':
        return 'En Progreso';
      default:
        return 'Inactivo';
    }
  }

  Color _getProgressColor(int progress) {
    if (progress >= 75) return AppColors.success;
    if (progress >= 50) return AppColors.warning;
    return AppColors.error;
  }
}