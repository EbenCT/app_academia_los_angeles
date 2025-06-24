// lib/screens/courses/subject_lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/screens/screen_base.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../config/routes.dart';
import '../../models/lesson_models.dart';
import '../../services/topic_lesson_service.dart';
import '../../services/graphql_service.dart';

enum LessonNodeType { lesson, game }

class LessonNode {
  final int id;
  final String title;
  final LessonNodeType type;
  final bool isUnlocked;
  final bool isCompleted;
  final String? description;
  final int? topicId;
  final Lesson? lessonData; // Datos reales del backend

  const LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    this.description,
    this.topicId,
    this.lessonData,
  });

  LessonNode copyWith({
    int? id,
    String? title,
    LessonNodeType? type,
    bool? isUnlocked,
    bool? isCompleted,
    String? description,
    int? topicId,
    Lesson? lessonData,
  }) {
    return LessonNode(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      topicId: topicId ?? this.topicId,
      lessonData: lessonData ?? this.lessonData,
    );
  }
}

class SubjectLessonsScreen extends StatefulWidget {
  final dynamic subject;

  const SubjectLessonsScreen({super.key, required this.subject});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  late List<LessonNode> lessons;
  late TopicLessonService _topicLessonService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadLessonsFromBackend();
  }

  void _initializeService() async {
    final client = await GraphQLService.getClient();
    _topicLessonService = TopicLessonService(client);
  }

  Future<void> _loadLessonsFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener topics y lecciones del backend
      final subjectData = await _topicLessonService.getSubjectTopics(widget.subject.id.toString());
      
      final topics = (subjectData['topics'] as List)
          .map((topicJson) => Topic.fromJson(topicJson))
          .toList();

      // Convertir a LessonNodes
      List<LessonNode> backendLessons = [];
      int nodeIndex = 0;

      for (final topic in topics) {
        for (final lesson in topic.lessons) {
          nodeIndex++;
          backendLessons.add(LessonNode(
            id: lesson.id,
            title: lesson.title,
            type: lesson.exercises.isEmpty ? LessonNodeType.lesson : LessonNodeType.lesson,
            isUnlocked: nodeIndex == 1, // La primera siempre desbloqueada
            isCompleted: false,
            description: lesson.content,
            topicId: topic.id,
            lessonData: lesson,
          ));
        }
      }

      // Cargar progreso guardado
      await _loadLessonProgress(backendLessons);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('Error cargando lecciones: $e');
    }
  }

  Future<void> _loadLessonProgress(List<LessonNode> backendLessons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons_v2';
      final progressJson = prefs.getStringList(subjectKey) ?? [];

      if (progressJson.isNotEmpty) {
        // Cargar progreso guardado
        final Map<int, Map<String, bool>> savedProgress = {};
        
        for (String progressString in progressJson) {
          final parts = progressString.split('|');
          if (parts.length >= 3) {
            final id = int.parse(parts[0]);
            savedProgress[id] = {
              'isUnlocked': parts[1] == 'true',
              'isCompleted': parts[2] == 'true',
            };
          }
        }

        // Aplicar progreso a las lecciones del backend
        lessons = backendLessons.map((lesson) {
          final progress = savedProgress[lesson.id];
          if (progress != null) {
            return lesson.copyWith(
              isUnlocked: progress['isUnlocked']!,
              isCompleted: progress['isCompleted']!,
            );
          }
          return lesson;
        }).toList();

        print('Progreso de lecciones cargado para materia ${widget.subject.name}');
      } else {
        // No hay progreso guardado, usar lecciones del backend
        lessons = backendLessons;
        print('Usando lecciones del backend para materia ${widget.subject.name}');
      }
    } catch (e) {
      print('Error cargando progreso de lecciones: $e');
      lessons = backendLessons;
    }
  }

  Future<void> _saveLessonProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons_v2';
      
      final progressStrings = lessons.map((lesson) {
        return '${lesson.id}|${lesson.isUnlocked}|${lesson.isCompleted}';
      }).toList();
      
      await prefs.setStringList(subjectKey, progressStrings);
      print('Progreso de lecciones guardado para materia ${widget.subject.name}');
    } catch (e) {
      print('Error guardando progreso de lecciones: $e');
    }
  }

  void _completeLessonNode(int lessonId) async {
    setState(() {
      final lessonIndex = lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (lessonIndex != -1) {
        lessons[lessonIndex] = lessons[lessonIndex].copyWith(isCompleted: true);
        
        // Desbloquear la siguiente lección
        if (lessonIndex + 1 < lessons.length) {
          lessons[lessonIndex + 1] = lessons[lessonIndex + 1].copyWith(isUnlocked: true);
        }
      }
    });

    await _saveLessonProgress();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Lección completada! ${_getNextLessonMessage(lessonId)}',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _getNextLessonMessage(int completedLessonId) {
    final currentIndex = lessons.indexWhere((lesson) => lesson.id == completedLessonId);
    if (currentIndex != -1 && currentIndex + 1 < lessons.length) {
      return 'Se desbloqueó: ${lessons[currentIndex + 1].title}';
    }
    return '¡Has completado todas las lecciones disponibles!';
  }

  void _handleLessonTap(LessonNode lesson) {
    if (lesson.lessonData != null) {
      // Navegar a la pantalla de lección dinámica
      Navigator.pushNamed(
        context,
        AppRoutes.dynamicLesson,
        arguments: {
          'lesson': lesson.lessonData,
          'onComplete': () => _completeLessonNode(lesson.id),
        },
      );
    } else {
      _showLockedMessage();
    }
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Completa las lecciones anteriores para desbloquear esta',
          style: TextStyle(fontFamily: 'Comic Sans MS'),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ScreenBase.forStudent(
        title: widget.subject.name,
        showBackButton: true,
        isLoading: true,
        loadingMessage: 'Cargando lecciones...',
        body: Container(),
      );
    }

    if (_errorMessage != null) {
      return ScreenBase.forStudent(
        title: widget.subject.name,
        showBackButton: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                'Error al cargar las lecciones',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadLessonsFromBackend,
                icon: Icon(Icons.refresh),
                label: Text(
                  'Reintentar',
                  style: TextStyle(fontFamily: 'Comic Sans MS'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            SliverToBoxAdapter(
              child: _buildSubjectHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildLessonsPath(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader() {
    final completedCount = lessons.where((l) => l.isCompleted).length;
    final totalCount = lessons.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.school, 
                completedCount.toString(), 
                totalCount.toString(), 
                'Completadas',
                AppColors.primary,
                showFraction: true,
              ),
              _buildStatItem(
                Icons.trending_up, 
                '${(progress * 100).round()}%', 
                '', 
                'Progreso',
                AppColors.success,
              ),
              _buildStatItem(
                Icons.stars, 
                '${lessons.where((l) => l.isUnlocked).length}', 
                '', 
                'Desbloqueadas',
                AppColors.secondary,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Barra de progreso
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String total, String label, Color color, {bool showFraction = false}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          showFraction && total.isNotEmpty ? '$value/$total' : value,
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
          const SizedBox(height: 100),
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
          onTap: lesson.isUnlocked ? () => _handleLessonTap(lesson) : () => _showLockedMessage(),
          child: Column(
            children: [
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
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: lesson.isUnlocked ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: lesson.isUnlocked ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: lesson.isUnlocked ? AppColors.textPrimary : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getNodeColor(LessonNode lesson) {
    if (lesson.isCompleted) return AppColors.success;
    if (lesson.isUnlocked) return AppColors.primary;
    return Colors.grey.shade400;
  }

  Color _getNodeBorderColor(LessonNode lesson) {
    if (lesson.isCompleted) return AppColors.success.withOpacity(0.8);
    if (lesson.isUnlocked) return AppColors.primary.withOpacity(0.8);
    return Colors.grey.shade500;
  }

  Color _getNodeIconColor(LessonNode lesson) {
    if (lesson.isCompleted) return Colors.white;
    if (lesson.isUnlocked) return Colors.white;
    return Colors.grey.shade600;
  }

  IconData _getNodeIcon(LessonNode lesson) {
    if (lesson.type == LessonNodeType.game) {
      return Icons.videogame_asset;
    }
    return Icons.school;
  }
}