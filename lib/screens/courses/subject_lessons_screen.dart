// lib/screens/courses/subject_lessons_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/screens/screen_base.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../config/routes.dart';

enum LessonType { lesson, game }

class LessonNode {
  final int id;
  final String title;
  final LessonType type;
  final bool isUnlocked;
  final bool isCompleted;
  final String? description;

  const LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    this.description,
  });
}

class SubjectLessonsScreen extends StatefulWidget {
  final dynamic subject;

  const SubjectLessonsScreen({super.key, required this.subject});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  late List<LessonNode> lessons;

  @override
  void initState() {
    super.initState();
    _initializeLessons();
  }

  void _initializeLessons() {
    // Por ahora, creamos lecciones de ejemplo
    // En el futuro, esto vendría del backend
    lessons = [
      LessonNode(
        id: 1,
        title: 'Introducción a los números enteros',
        type: LessonType.lesson,
        isUnlocked: true,
        isCompleted: false,
        description: 'Aprende qué son los números enteros',
      ),
      LessonNode(
        id: 2,
        title: 'Rescate de alturas',
        type: LessonType.game,
        isUnlocked: false, // Se desbloquea al completar la lección anterior
        isCompleted: false,
        description: 'Practica con números enteros en un juego divertido',
      ),
    ];
  }

  void _completeLessonNode(int lessonId) {
    setState(() {
      // Marcar la lección como completada
      final lessonIndex = lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (lessonIndex != -1) {
        lessons[lessonIndex] = LessonNode(
          id: lessons[lessonIndex].id,
          title: lessons[lessonIndex].title,
          type: lessons[lessonIndex].type,
          isUnlocked: lessons[lessonIndex].isUnlocked,
          isCompleted: true,
          description: lessons[lessonIndex].description,
        );
        
        // Desbloquear la siguiente lección
        if (lessonIndex + 1 < lessons.length) {
          lessons[lessonIndex + 1] = LessonNode(
            id: lessons[lessonIndex + 1].id,
            title: lessons[lessonIndex + 1].title,
            type: lessons[lessonIndex + 1].type,
            isUnlocked: true,
            isCompleted: lessons[lessonIndex + 1].isCompleted,
            description: lessons[lessonIndex + 1].description,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: widget.subject.name,
      showBackButton: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Información de la materia
            SliverToBoxAdapter(
              child: _buildSubjectHeader(),
            ),
            
            // Path de lecciones estilo Duolingo
            SliverToBoxAdapter(
              child: _buildLessonsPath(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icono de la materia
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.calculate, // Esto debería ser dinámico basado en la materia
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.subject.name,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (widget.subject.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subject.description!,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonsPath() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (int i = 0; i < lessons.length; i++) ...[
            _buildLessonNode(lessons[i], i),
            if (i < lessons.length - 1) _buildConnector(),
          ],
          const SizedBox(height: 100), // Espacio extra al final
        ],
      ),
    );
  }

  Widget _buildLessonNode(LessonNode lesson, int index) {
    final bool isLeft = index % 2 == 0;
    
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 80,
        right: isLeft ? 80 : 0,
        top: 20,
        bottom: 20,
      ),
      child: BounceAnimation(
        child: GestureDetector(
          onTap: lesson.isUnlocked ? () => _handleLessonTap(lesson) : null,
          child: Column(
            children: [
              // Nodo principal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNodeColor(lesson),
                  border: Border.all(
                    color: _getNodeBorderColor(lesson),
                    width: 4,
                  ),
                  boxShadow: lesson.isUnlocked ? [
                    BoxShadow(
                      color: _getNodeColor(lesson).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getNodeIcon(lesson),
                      color: _getNodeIconColor(lesson),
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    if (lesson.isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Título de la lección
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: lesson.isUnlocked 
                      ? Colors.white 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: lesson.isUnlocked 
                        ? AppColors.primary.withOpacity(0.3) 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: lesson.isUnlocked 
                        ? AppColors.primary 
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getNodeColor(LessonNode lesson) {
    if (!lesson.isUnlocked) return Colors.grey.shade300;
    if (lesson.isCompleted) return AppColors.success;
    return lesson.type == LessonType.lesson 
        ? AppColors.primary 
        : AppColors.secondary;
  }

  Color _getNodeBorderColor(LessonNode lesson) {
    if (!lesson.isUnlocked) return Colors.grey.shade400;
    if (lesson.isCompleted) return AppColors.success;
    return lesson.type == LessonType.lesson 
        ? AppColors.primary 
        : AppColors.secondary;
  }

  Color _getNodeIconColor(LessonNode lesson) {
    if (!lesson.isUnlocked) return Colors.grey.shade500;
    return Colors.white;
  }

  IconData _getNodeIcon(LessonNode lesson) {
    if (!lesson.isUnlocked) return Icons.lock;
    return lesson.type == LessonType.lesson 
        ? Icons.school 
        : Icons.videogame_asset;
  }

  void _handleLessonTap(LessonNode lesson) {
    if (lesson.type == LessonType.lesson) {
      // Navegar a la lección interactiva
      Navigator.pushNamed(context, AppRoutes.integerLesson).then((result) {
        // Si la lección se completó, actualizar el estado
        if (result == true) {
          _completeLessonNode(lesson.id);
        }
      });
    } else {
      // Navegar al juego
      Navigator.pushNamed(context, AppRoutes.integerRescueGame).then((result) {
        // Si el juego se completó, actualizar el estado
        if (result == true) {
          _completeLessonNode(lesson.id);
        }
      });
    }
  }
}