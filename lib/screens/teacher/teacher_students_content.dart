// lib/screens/teacher/teacher_students_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/student_tracking_provider.dart';
import '../../models/classroom_model.dart';
import '../../models/student_tracking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animations/fade_animation.dart';
import 'student_detail_screen.dart';

class TeacherStudentsContent extends StatefulWidget {
  const TeacherStudentsContent({super.key});

  @override
  State<TeacherStudentsContent> createState() => _TeacherStudentsContentState();
}

class _TeacherStudentsContentState extends State<TeacherStudentsContent> {
  ClassroomModel? _selectedClassroom;
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassrooms();
    });
  }

  Future<void> _loadClassrooms() async {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
    if (classroomProvider.classrooms.isEmpty) {
      await classroomProvider.fetchTeacherClassrooms();
    }
  }

  Future<void> _onClassroomSelected(ClassroomModel? classroom) async {
    if (classroom == null) return;
    
    setState(() {
      _selectedClassroom = classroom;
      _isLoadingStudents = true;
    });

    final trackingProvider = Provider.of<StudentTrackingProvider>(context, listen: false);
    await trackingProvider.loadClassroomStudents(classroom.id);

    setState(() {
      _isLoadingStudents = false;
    });
  }

  void _onStudentTapped(StudentTrackingModel student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar personalizada
          _buildAppBar(),
          
          // Contenido principal
          Expanded(
            child: _buildMainContent(),
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
          const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lista de Estudiantes',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer2<ClassroomProvider, StudentTrackingProvider>(
      builder: (context, classroomProvider, trackingProvider, child) {
        if (classroomProvider.isLoading) {
          return const LoadingIndicator(
            message: 'Cargando aulas...',
            useAstronaut: true,
          );
        }

        if (classroomProvider.classrooms.isEmpty) {
          return _buildEmptyClassroomsState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de aula
              _buildClassroomSelector(classroomProvider.classrooms),
              const SizedBox(height: 20),
              
              // Lista de estudiantes
              _buildStudentsSection(trackingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassroomSelector(List<ClassroomModel> classrooms) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 200),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Aula',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassroomModel>(
                  value: _selectedClassroom,
                  hint: const Text(
                    'Selecciona un aula para ver estudiantes',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: classrooms.map((classroom) {
                    return DropdownMenuItem<ClassroomModel>(
                      value: classroom,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.class_,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  classroom.name,
                                  style: const TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${classroom.studentsCount} estudiantes • ${classroom.courseName}',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onClassroomSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSection(StudentTrackingProvider trackingProvider) {
    if (_selectedClassroom == null) {
      return _buildSelectClassroomPrompt();
    }

    if (_isLoadingStudents || trackingProvider.isLoading) {
      return const LoadingIndicator(
        message: 'Cargando estudiantes...',
        useAstronaut: true,
      );
    }

    if (trackingProvider.error != null) {
      return _buildErrorState(trackingProvider.error!);
    }

    final students = trackingProvider.students;

    if (students.isEmpty) {
      return _buildEmptyStudentsState();
    }

    return FadeAnimation(
      delay: const Duration(milliseconds: 400),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estadísticas
            _buildStudentsHeader(students),
            const SizedBox(height: 16),
            
            // Lista de estudiantes
            ...students.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              
              return FadeAnimation(
                delay: Duration(milliseconds: 100 * (index + 1)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildStudentCard(student),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsHeader(List<StudentTrackingModel> students) {
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
            child: _buildStatItem('Total', '$totalStudents', AppColors.secondary, Icons.people),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem('Activos', '$activeStudents', AppColors.success, Icons.check_circle),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem('Progreso', '${averageProgress.round()}%', AppColors.primary, Icons.trending_up),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
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

  Widget _buildStudentCard(StudentTrackingModel student) {
    return InkWell(
      onTap: () => _onStudentTapped(student),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
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
              radius: 25,
              backgroundColor: _getStatusColor(student.estado),
              child: Text(
                student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'E',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del estudiante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nivel ${student.nivelActual} • ${student.ultimaActividad}',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: student.avance / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(student.avance),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${student.avance}%',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(student.avance),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Estado y flecha
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(student.estado).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(student.estado),
                        size: 14,
                        color: _getStatusColor(student.estado),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(student.estado),
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(student.estado),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyClassroomsState() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_outlined,
              size: 80,
              color: AppColors.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes aulas creadas',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Crea tu primera aula desde la pantalla de inicio para comenzar a hacer seguimiento a tus estudiantes.',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectClassroomPrompt() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 400),
      child: AppCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_upward,
                size: 60,
                color: AppColors.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona un aula',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa el selector de arriba para elegir un aula y ver sus estudiantes',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStudentsState() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 400),
      child: AppCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay estudiantes en esta aula',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
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
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: AppCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar estudiantes',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares para colores y estados
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

  Future<void> _refreshData() async {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
    final trackingProvider = Provider.of<StudentTrackingProvider>(context, listen: false);
    
    await classroomProvider.fetchTeacherClassrooms();
    if (_selectedClassroom != null) {
      await trackingProvider.refresh();
    }
  }
}