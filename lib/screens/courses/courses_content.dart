// lib/screens/courses/courses_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // Cargar datos si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      if (studentProvider.subjects.isEmpty) {
        studentProvider.refreshStudentData();
      }
    });
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
          Text(
            'Mis Materias',
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
              onPressed: () {
                Provider.of<StudentProvider>(context, listen: false)
                    .refreshStudentData();
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
      onRefresh: () => studentProvider.refreshStudentData(),
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
                return FadeAnimation(
                  delay: Duration(milliseconds: 200 + (index * 100)),
                  child: _buildSubjectCard(subject, index),
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
              onPressed: () {
                Provider.of<StudentProvider>(context, listen: false)
                    .refreshStudentData();
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

  Widget _buildSubjectCard(subject, int index) {
    final IconData icon = AppIcons.getCourseIcon(subject.name);
    final Color color = AppIcons.getCourseColor(index);
    
    return AppCard(
      onTap: () {
        // Navegar a la pantalla de lecciones de la materia específica
        Navigator.pushNamed(
          context,
          '/subject-lessons',
          arguments: subject,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icono de la materia
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
            
            // Nombre de la materia (una sola línea)
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
            
            // Descripción si existe (máximo 2 líneas)
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
            
            // Progreso placeholder
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.0, // Sin progreso por ahora
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '0% completado',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}