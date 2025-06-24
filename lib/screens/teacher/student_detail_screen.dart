// lib/screens/teacher/student_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/student_tracking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../services/export_service_extensions.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentTrackingModel student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar personalizada
            _buildAppBar(context),
            
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                    _buildExportButtons(context),
                    
                    const SizedBox(height: 100), // Espacio extra al final
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detalle del Estudiante',
              style: const TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareStudentData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 200),
      child: AppCard(
        child: Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              // Avatar y nombre
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: const TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 22,
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
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Información básica en fila
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Nivel',
                      '${student.nivelActual}',
                      AppColors.accent,
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Experiencia',
                      '${student.xp} XP',
                      AppColors.primary,
                      Icons.star,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Estado',
                      _getStatusText(student.estado),
                      _getStatusColor(student.estado),
                      _getStatusIcon(student.estado),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Última actividad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'Última actividad: ${student.ultimaActividad}',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
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

  Widget _buildInfoItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
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

  Widget _buildMainMetrics() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: AppCard(
        child: Column(
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Avance General', 
                    '${student.avance}%', 
                    AppColors.primary, 
                    Icons.trending_up
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Tiempo Dedicado', 
                    '${student.tiempoDedicado}m', 
                    AppColors.secondary, 
                    Icons.schedule
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Aciertos', 
                    '${student.porcentajeAciertos}%', 
                    AppColors.success, 
                    Icons.check_circle
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Errores', 
                    '${student.porcentajeErrores}%', 
                    AppColors.error, 
                    Icons.error
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          Icon(icon, color: color, size: 28),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 400),
      child: AppCard(
        child: Column(
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
            const SizedBox(height: 16),
            ...student.progressoMaterias.map((subject) => _buildSubjectProgressBar(subject)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgressBar(SubjectProgressModel subject) {
    final progressColor = _getProgressColor(subject.progress);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: progressColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${subject.progress}%',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tiempo dedicado: ${subject.timeSpent} minutos',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: subject.progress / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 500),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exportar Datos del Estudiante',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    context,
                    'Exportar PDF',
                    Icons.picture_as_pdf,
                    AppColors.error,
                    () => _exportToPDF(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExportButton(
                    context,
                    'Exportar Excel',
                    Icons.table_chart,
                    AppColors.success,
                    () => _exportToExcel(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    String title, 
    IconData icon, 
    Color color, 
    VoidCallback onTap
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
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

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      await ExportServiceExtensions.exportStudentToPDF(
        student: student, 
        context: context
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al exportar PDF: $e',
            style: const TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      await ExportServiceExtensions.exportStudentToExcel(
        student: student, 
        context: context
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al exportar Excel: $e',
            style: const TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _shareStudentData(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Compartir Datos del Estudiante',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('Compartir como PDF'),
              subtitle: const Text('Reporte completo del estudiante'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Compartir como Excel'),
              subtitle: const Text('Datos detallados en hoja de cálculo'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}