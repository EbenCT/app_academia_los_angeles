// lib/widgets/teacher/student_detail_panel_widget.dart
import 'package:flutter/material.dart';
import '../../models/student_tracking_model.dart';
import '../../theme/app_colors.dart';
import '../common/app_card.dart';
import '../animations/fade_animation.dart';

class StudentDetailPanelWidget extends StatelessWidget {
  final StudentTrackingModel student;
  final VoidCallback onExportPDF;
  final VoidCallback onExportExcel;

  const StudentDetailPanelWidget({
    super.key,
    required this.student,
    required this.onExportPDF,
    required this.onExportExcel,
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del estudiante
            _buildStudentHeader(),
            const SizedBox(height: 20),
            
            // Métricas principales
            _buildMainMetrics(),
            const SizedBox(height: 20),
            
            // Progreso por materias
            _buildSubjectProgress(),
            const SizedBox(height: 20),
            
            // Botones de exportación
            _buildExportButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar del estudiante
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'E',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información básica
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(student.estado),
              ],
            ),
          ),
          
          // Nivel y XP
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nivel ${student.nivelActual}',
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${student.xp} XP',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'activo':
        color = AppColors.success;
        icon = Icons.check_circle;
        text = 'Activo';
        break;
      case 'en_progreso':
        color = AppColors.warning;
        icon = Icons.schedule;
        text = 'En Progreso';
        break;
      default:
        color = AppColors.error;
        icon = Icons.pause_circle;
        text = 'Inactivo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas de Rendimiento',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Avance', '${student.avance}%', AppColors.primary, Icons.trending_up)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Tiempo', '${student.tiempoDedicado}m', AppColors.secondary, Icons.schedule)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Aciertos', '${student.porcentajeAciertos}%', AppColors.success, Icons.check_circle)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Errores', '${student.porcentajeErrores}%', AppColors.error, Icons.error)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 20,
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
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progreso por Materias',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...student.progressoMaterias.map((subject) => _buildSubjectProgressBar(subject)),
      ],
    );
  }

  Widget _buildSubjectProgressBar(SubjectProgressModel subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${subject.progress}% • ${subject.timeSpent}m',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: subject.progress / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              subject.progress >= 75 ? AppColors.success :
              subject.progress >= 50 ? AppColors.warning : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exportar Datos',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                'PDF',
                Icons.picture_as_pdf,
                AppColors.error,
                onExportPDF,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                'Excel',
                Icons.table_chart,
                AppColors.success,
                onExportExcel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Exportar $title',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}