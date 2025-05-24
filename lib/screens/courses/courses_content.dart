// lib/screens/courses/courses_content.dart (completo y ordenado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../services/lesson_progress_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/app_card.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_icons.dart';

class CoursesContent extends StatefulWidget {
  const CoursesContent({super.key});

  @override
  State<CoursesContent> createState() => _CoursesContentState();
}

class _CoursesContentState extends State<CoursesContent> {
  Map<int, Map<String, dynamic>> _subjectsProgress = {};
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      if (studentProvider.subjects.isEmpty) {
        studentProvider.refreshStudentData().then((_) => _loadProgress());
      } else {
        _loadProgress();
      }
    });
  }

  Future<void> _loadProgress() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final subjects = studentProvider.subjects;
    
    if (subjects.isNotEmpty) {
      final progress = await LessonProgressService.getAllSubjectsProgress(subjects);
      if (mounted) {
        setState(() {
          _subjectsProgress = progress;
          _progressLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    
    return SafeArea(
      child: Column(
        children: [
          // App Bar personalizada
          _buildAppBar(),
          
          // Contenido
          Expanded(
            child: studentProvider.isLoading
                ? LoadingIndicator(
                    message: 'Cargando tus materias...',
                    useAstronaut: true,
                  )
                : studentProvider.error != null
                    ? _buildErrorState(studentProvider.error!)
                    : _buildSubjectsGrid(studentProvider),
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
          Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mis Materias',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Mostrar progreso general si está disponible
          if (_progressLoaded && _subjectsProgress.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_calculateOverallProgress()}%',
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

  int _calculateOverallProgress() {
    if (_subjectsProgress.isEmpty) return 0;
    
    double totalProgress = 0.0;
    for (var progress in _subjectsProgress.values) {
      totalProgress += progress['progress'] as double;
    }
    
    return ((totalProgress / _subjectsProgress.length) * 100).round();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar materias',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Provider.of<StudentProvider>(context, listen: false)
                    .refreshStudentData();
                await _loadProgress();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsGrid(StudentProvider studentProvider) {
    final subjects = studentProvider.subjects;
    
    if (subjects.isEmpty) {
      return _buildNoSubjectsState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await studentProvider.refreshStudentData();
        await _loadProgress();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del curso
            if (studentProvider.courseName != null) ...[
              FadeAnimation(
                delay: const Duration(milliseconds: 100),
                child: AppCard(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  borderColor: AppColors.primary.withOpacity(0.3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Curso: ${studentProvider.courseName}',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (studentProvider.classroomName != null)
                              Text(
                                'Aula: ${studentProvider.classroomName}',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Mostrar estadísticas generales
                      if (_progressLoaded && _subjectsProgress.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              '${_calculateOverallProgress()}%',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Completado',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Grid de materias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final progress = _subjectsProgress[subject.id] ?? {
                  'progress': 0.0,
                  'completed': 0,
                  'total': 0,
                  'percentage': 0,
                };
                
                return FadeAnimation(
                  delay: Duration(milliseconds: 200 + (index * 100)),
                  child: _buildSubjectCard(subject, index, progress),
                );
              },
            ),
            
            const SizedBox(height: 100), // Espacio para el bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubjectsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay materias disponibles',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Habla con tu profesor para que configure las materias de tu curso',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Provider.of<StudentProvider>(context, listen: false)
                    .refreshStudentData();
                await _loadProgress();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(subject, int index, Map<String, dynamic> progress) {
    final IconData icon = AppIcons.getCourseIcon(subject.name);
    final Color color = AppIcons.getCourseColor(index);
    final double progressValue = progress['progress'] as double;
    final int completed = progress['completed'] as int;
    final int total = progress['total'] as int;
    final int percentage = progress['percentage'] as int;
    
    return AppCard(
      onTap: () {
        // Navegar a la pantalla de lecciones de la materia específica
        Navigator.pushNamed(
          context,
          '/subject-lessons',
          arguments: subject,
        ).then((_) {
          // Recargar progreso cuando se regrese
          _loadProgress();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icono de la materia con badge de progreso
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                // Badge de progreso
                if (total > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getProgressColor(progressValue),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: progressValue >= 1.0
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              )
                            : Text(
                                '$percentage',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Nombre de la materia
            Text(
              subject.name,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Descripción si existe
            if (subject.description != null && subject.description!.isNotEmpty)
              Text(
                subject.description!,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              // Placeholder para mantener la altura consistente
              SizedBox(height: 22),
            
            // Progreso mejorado
            Column(
              children: [
                // Barra de progreso
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progressValue,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getProgressColor(progressValue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Texto de progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      total > 0 ? '$completed/$total' : 'Sin lecciones',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(progressValue),
                          ),
                        ),
                        if (progressValue >= 1.0) ...[
                          const SizedBox(width: 2),
                          Icon(
                            Icons.star,
                            color: AppColors.star,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.star;
    if (progress >= 0.3) return AppColors.primary;
    return Colors.grey;
  }
}