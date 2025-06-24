// lib/screens/courses/courses_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../services/lesson_progress_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/app_card.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../config/routes.dart'; // IMPORTANTE: Agregar este import

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
                    : _buildSubjectsList(studentProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 Mis Materias',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selecciona una materia para comenzar',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              'Error al cargar las materias',
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

  Widget _buildSubjectsList(StudentProvider studentProvider) {
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
          children: [
            // Grid de materias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final progress = _progressLoaded 
                    ? _subjectsProgress[subject.id] ?? {
                        'progress': 0.0,
                        'completed': 0,
                        'total': 0,
                        'percentage': 0,
                      }
                    : {
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
      // CORREGIDO: Navegar a la pantalla de topics en lugar de directamente a lecciones
      AppRoutes.navigateToSubjectTopics(context, subject);
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de la materia
          Container(
            padding: const EdgeInsets.all(12), // Reducido de 16 a 12
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
            ),
            child: Icon(
              icon,
              size: 32, // Reducido de 40 a 32
              color: color,
            ),
          ),
          
          const SizedBox(height: 8), // Reducido de 12 a 8
          
          // Nombre de la materia - CORREGIDO PARA EVITAR DESBORDAMIENTO
          Flexible( // Cambiado de Container a Flexible
            child: Text(
              subject.name,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14, // Reducido de 16 a 14
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 6), // Reducido de 8 a 6
          
          // Progreso
          if (_progressLoaded) ...[
            // Barra de progreso
            Container(
              width: double.infinity,
              height: 4, // Reducido de 6 a 4
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 6), // Reducido de 8 a 6
            
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Añadido Flexible
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 11, // Reducido de 12 a 11
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible( // Añadido Flexible
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 11, // Reducido de 12 a 11
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Indicador de carga
            Container(
              width: double.infinity,
              height: 4, // Reducido de 6 a 4
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6), // Reducido de 8 a 6
            Text(
              'Cargando...',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 11, // Reducido de 12 a 11
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}