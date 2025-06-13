// lib/screens/teacher/teacher_progress_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../../models/classroom_model.dart';
import '../../providers/classroom_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../utils/app_snackbars.dart';
import '../../services/export_service.dart';

class TeacherProgressDashboard extends StatefulWidget {
  const TeacherProgressDashboard({super.key});

  @override
  State<TeacherProgressDashboard> createState() => _TeacherProgressDashboardState();
}

class _TeacherProgressDashboardState extends State<TeacherProgressDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar personalizada
            _buildAppBar(),
            
            // Contenido
            Expanded(
              child: _isLoading
                  ? LoadingIndicator(
                      message: 'Cargando métricas de tus estudiantes...',
                      useAstronaut: true,
                      size: 150,
                    )
                  : _buildContent(),
            ),
          ],
        ),
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
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seguimiento de Progreso',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ClassroomProvider>(
      builder: (context, classroomProvider, child) {
        final classrooms = classroomProvider.classrooms;
        
        if (classrooms.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () async {
            await classroomProvider.fetchTeacherClassrooms();
            await _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen general
                _buildGeneralSummary(classrooms),
                const SizedBox(height: 24),
                
                // Lista de aulas con métricas
                ...classrooms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final classroom = entry.value;
                  return FadeAnimation(
                    delay: Duration(milliseconds: 200 * (index + 1)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildClassroomCard(classroom),
                    ),
                  );
                }).toList(),
                
                // Botón de exportar
                const SizedBox(height: 24),
                _buildExportSection(),
                
                const SizedBox(height: 100), // Espacio para navegación
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              AssetPaths.emptyAnimation,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay aulas para mostrar',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera aula para ver las métricas de progreso',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSummary(List<ClassroomModel> classrooms) {
    final totalStudents = classrooms.fold<int>(0, (sum, classroom) => sum + classroom.studentsCount);
    final totalClassrooms = classrooms.length;
    final averageProgress = _calculateAverageProgress(classrooms);
    final activeStudents = _calculateActiveStudents(totalStudents);

    return FadeAnimation(
      delay: const Duration(milliseconds: 100),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumen General',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.school,
                    label: 'Aulas',
                    value: totalClassrooms.toString(),
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.people,
                    label: 'Estudiantes',
                    value: totalStudents.toString(),
                    color: AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.trending_up,
                    label: 'Progreso Prom.',
                    value: '${averageProgress.round()}%',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.person_pin,
                    label: 'Activos Hoy',
                    value: activeStudents.toString(),
                    color: AppColors.star,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
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
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildClassroomCard(ClassroomModel classroom) {
    final metrics = _generateClassroomMetrics(classroom);
    
    return AppCard(
      borderColor: AppColors.secondary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del aula
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.class_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classroom.name,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '${classroom.courseName} • ${classroom.studentsCount} estudiantes',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppColors.secondary),
                onPressed: () => _showClassroomOptions(context, classroom),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Métricas del aula
          Row(
            children: [
              Expanded(
                child: _buildClassroomMetric(
                  'Participación',
                  '${metrics['participation']}%',
                  Icons.forum,
                  _getColorForPercentage(metrics['participation']),
                ),
              ),
              Expanded(
                child: _buildClassroomMetric(
                  'Rendimiento',
                  '${metrics['performance']}%',
                  Icons.grade,
                  _getColorForPercentage(metrics['performance']),
                ),
              ),
              Expanded(
                child: _buildClassroomMetric(
                  'Tiempo (hrs)',
                  '${metrics['timeSpent']}h',
                  Icons.access_time,
                  AppColors.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso general del aula
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso General del Aula',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${metrics['overall']}%',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: metrics['overall'] / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForPercentage(metrics['overall']),
                  ),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 600),
      child: AppCard(
        borderColor: AppColors.info.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: AppColors.info,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exportar Datos',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Descarga reportes detallados del progreso de tus estudiantes en diferentes formatos.',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToPDF(),
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToExcel(),
                    icon: Icon(Icons.table_chart),
                    label: Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para generar datos estáticos
  Map<String, dynamic> _generateClassroomMetrics(ClassroomModel classroom) {
    // Generar métricas basadas en el ID del aula para consistencia
    final seed = classroom.id;
    final participation = 60 + (seed % 35); // 60-95%
    final performance = 55 + (seed % 40); // 55-95%
    final timeSpent = 2 + (seed % 8); // 2-10 horas
    final overall = ((participation + performance) / 2).round();
    
    return {
      'participation': participation,
      'performance': performance,
      'timeSpent': timeSpent,
      'overall': overall,
    };
  }

  double _calculateAverageProgress(List<ClassroomModel> classrooms) {
    if (classrooms.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final classroom in classrooms) {
      final metrics = _generateClassroomMetrics(classroom);
      totalProgress += metrics['overall'];
    }
    
    return totalProgress / classrooms.length;
  }

  int _calculateActiveStudents(int totalStudents) {
    // Simular estudiantes activos (70-90% del total)
    return (totalStudents * (0.7 + (DateTime.now().day % 20) / 100)).round();
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  void _showClassroomOptions(BuildContext context, ClassroomModel classroom) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              classroom.name,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: Text('Ver detalles'),
              onTap: () {
                Navigator.pop(context);
                _viewClassroomDetails(classroom);
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: AppColors.secondary),
              title: Text('Ver estudiantes'),
              onTap: () {
                Navigator.pop(context);
                _viewStudents(classroom);
              },
            ),
            ListTile(
              leading: Icon(Icons.file_download, color: AppColors.info),
              title: Text('Exportar datos del aula'),
              onTap: () {
                Navigator.pop(context);
                _exportClassroomData(classroom);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewClassroomDetails(ClassroomModel classroom) {
    AppSnackbars.showInfoSnackBar(
      context,
      message: 'Función en desarrollo: Detalles de ${classroom.name}',
    );
  }

  void _viewStudents(ClassroomModel classroom) {
    AppSnackbars.showInfoSnackBar(
      context,
      message: 'Función en desarrollo: Estudiantes de ${classroom.name}',
    );
  }

  void _exportClassroomData(ClassroomModel classroom) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exportar datos de ${classroom.name}',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Exportar a PDF'),
              subtitle: Text('Reporte completo del aula'),
              onTap: () {
                Navigator.pop(context);
                ExportService.exportClassroomToPDF(
                  classroom: classroom,
                  context: context,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green),
              title: Text('Exportar a Excel'),
              subtitle: Text('Datos detallados en hoja de cálculo'),
              onTap: () {
                Navigator.pop(context);
                ExportService.exportClassroomToExcel(
                  classroom: classroom,
                  context: context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF() {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
    final classrooms = classroomProvider.classrooms;
    
    if (classrooms.isEmpty) {
      AppSnackbars.showWarningSnackBar(
        context,
        message: 'No hay aulas para exportar',
      );
      return;
    }
    
    ExportService.exportGeneralReportToPDF(
      classrooms: classrooms,
      context: context,
    );
  }

  void _exportToExcel() {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
    final classrooms = classroomProvider.classrooms;
    
    if (classrooms.isEmpty) {
      AppSnackbars.showWarningSnackBar(
        context,
        message: 'No hay aulas para exportar',
      );
      return;
    }
    
    ExportService.exportGeneralReportToExcel(
      classrooms: classrooms,
      context: context,
    );
  }
}