// lib/screens/courses/subject_lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/screens/screen_base.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../config/routes.dart';
import '../../models/lesson_models.dart';
import '../../models/adaptive_lesson_models.dart';
import '../../services/topic_lesson_service.dart';
import '../../services/adaptive_exercise_service.dart';
import '../../services/graphql_service.dart';

enum LessonNodeType { lesson, game, adaptive }

class LessonNode {
  final int id;
  final String title;
  final LessonNodeType type;
  final bool isUnlocked;
  final bool isCompleted;
  final String? description;
  final int? topicId;
  final Lesson? lessonData;
  final SpecialLessonNode? specialNode;

  const LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    this.description,
    this.topicId,
    this.lessonData,
    this.specialNode,
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
    SpecialLessonNode? specialNode,
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
      specialNode: specialNode ?? this.specialNode,
    );
  }
}

class SubjectLessonsScreen extends StatefulWidget {
  final dynamic subject;

  const SubjectLessonsScreen({super.key, required this.subject, required topic});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  // ESTADO
  late List<LessonNode> lessons;
  late TopicLessonService _topicLessonService;
  late AdaptiveExerciseService _adaptiveService;
  bool _isLoading = true;
  String? _errorMessage;

  // INICIALIZACIÓN
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadLessonsFromBackend();
  }

  void _initializeServices() async {
    final client = await GraphQLService.getClient();
    _topicLessonService = TopicLessonService(client);
    _adaptiveService = AdaptiveExerciseService(client);
  }

  // CARGA DE DATOS
  Future<void> _loadLessonsFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final subjectData = await _topicLessonService.getSubjectTopics(widget.subject.id.toString());
      final topics = (subjectData['topics'] as List).map((topicJson) => Topic.fromJson(topicJson)).toList();

      List<LessonNode> backendLessons = [];
      int nodeIndex = 0;

      for (final topic in topics) {
        for (final lesson in topic.lessons) {
          nodeIndex++;
          backendLessons.add(LessonNode(
            id: lesson.id,
            title: lesson.title,
            type: LessonNodeType.lesson,
            isUnlocked: nodeIndex == 1,
            isCompleted: false,
            description: lesson.content,
            topicId: topic.id,
            lessonData: lesson,
          ));
        }
      }

      await _loadLessonProgress(backendLessons);
      await _generateSpecialNodes();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadLessonProgress(List<LessonNode> backendLessons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons_v3';
      final progressJson = prefs.getStringList(subjectKey) ?? [];

      if (progressJson.isNotEmpty) {
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
      } else {
        lessons = backendLessons;
      }
    } catch (e) {
      lessons = backendLessons;
    }
  }

  Future<void> _saveLessonProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons_v3';
      
      final progressStrings = lessons.map((lesson) {
        return '${lesson.id}|${lesson.isUnlocked}|${lesson.isCompleted}';
      }).toList();
      
      await prefs.setStringList(subjectKey, progressStrings);
    } catch (e) {
      print('Error guardando progreso: $e');
    }
  }

  // GENERACIÓN DE NODOS ESPECIALES
  Future<void> _generateSpecialNodes() async {
    final completedCount = lessons.where((l) => l.isCompleted && l.type == LessonNodeType.lesson).length;
    final specialNodesNeeded = (completedCount / 5).floor();
    
    List<LessonNode> specialNodes = [];
    
    for (int i = 1; i <= specialNodesNeeded; i++) {
      final requiredLessons = i * 5;
      final isUnlocked = completedCount >= requiredLessons;
      
      // Nodo de juego (Rescate en las Alturas)
      final gameNode = LessonNode(
        id: 1000 + (i * 2 - 1),
        title: '🎮 Rescate en las Alturas $i',
        type: LessonNodeType.game,
        isUnlocked: isUnlocked,
        isCompleted: false,
        description: 'Juego desbloqueado por completar $requiredLessons lecciones',
        specialNode: SpecialLessonNode.game(
          levelNumber: i,
          requiredCompletedLessons: requiredLessons,
          isUnlocked: isUnlocked,
        ),
      );
      
      // Nodo adaptativo
      AdaptiveLesson? adaptiveLesson;
      if (isUnlocked) {
        try {
          final adaptiveExercises = await _adaptiveService.getAdaptiveExercises();
          adaptiveLesson = AdaptiveLesson.fromExercises(
            exercises: adaptiveExercises,
            levelNumber: i,
            requiredCompletedLessons: requiredLessons,
            isUnlocked: true,
          );
        } catch (e) {
          adaptiveLesson = AdaptiveLesson.fromExercises(
            exercises: [],
            levelNumber: i,
            requiredCompletedLessons: requiredLessons,
            isUnlocked: true,
          );
        }
      }
      
      final adaptiveNode = LessonNode(
        id: 1000 + (i * 2),
        title: '🧠 Nivel Adaptativo $i',
        type: LessonNodeType.adaptive,
        isUnlocked: isUnlocked,
        isCompleted: false,
        description: 'Ejercicios personalizados según tu progreso',
        specialNode: SpecialLessonNode.adaptive(
          levelNumber: i,
          requiredCompletedLessons: requiredLessons,
          isUnlocked: isUnlocked,
          adaptiveLesson: adaptiveLesson!,
        ),
      );
      
      specialNodes.addAll([gameNode, adaptiveNode]);
    }
    
    _insertSpecialNodes(specialNodes);
  }

  void _insertSpecialNodes(List<LessonNode> specialNodes) {
    List<LessonNode> finalLessons = [];
    int regularLessonCount = 0;
    int specialNodeIndex = 0;
    
    for (final lesson in lessons) {
      if (lesson.type == LessonNodeType.lesson) {
        finalLessons.add(lesson);
        regularLessonCount++;
        
        if (regularLessonCount % 5 == 0 && specialNodeIndex < specialNodes.length - 1) {
          finalLessons.add(specialNodes[specialNodeIndex]);     // Juego
          finalLessons.add(specialNodes[specialNodeIndex + 1]); // Adaptativo
          specialNodeIndex += 2;
        }
      }
    }
    
    lessons = finalLessons;
  }

  // NAVEGACIÓN Y ACCIONES
  void _handleLessonTap(LessonNode lesson) {
    if (!lesson.isUnlocked) {
      _showLockedMessage();
      return;
    }

    switch (lesson.type) {
      case LessonNodeType.lesson:
        if (lesson.lessonData != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.dynamicLesson,
            arguments: {
              'lesson': lesson.lessonData,
              'onComplete': () => _completeLessonNode(lesson.id),
            },
          );
        }
        break;
        
      case LessonNodeType.game:
        // Navegar al juego Rescate en las Alturas
        Navigator.pushNamed(
          context,
          AppRoutes.integerRescueGame,
        ).then((_) {
          // Marcar como completado cuando regrese del juego
          _completeLessonNode(lesson.id);
        });
        break;
        
      case LessonNodeType.adaptive:
        _navigateToAdaptiveLevel(lesson);
        break;
    }
  }

  void _navigateToAdaptiveLevel(LessonNode adaptiveNode) {
    if (adaptiveNode.specialNode?.adaptiveLesson != null) {
      final adaptiveLesson = adaptiveNode.specialNode!.adaptiveLesson!;
      
      if (adaptiveLesson.exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No hay ejercicios adaptativos disponibles en este momento',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      Navigator.pushNamed(
        context,
        AppRoutes.dynamicLesson,
        arguments: {
          'lesson': adaptiveLesson.toStandardLesson(),
          'onComplete': () => _completeLessonNode(adaptiveNode.id),
        },
      );
    }
  }

  void _completeLessonNode(int lessonId) async {
    setState(() {
      final lessonIndex = lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (lessonIndex != -1) {
        lessons[lessonIndex] = lessons[lessonIndex].copyWith(isCompleted: true);
        
        if (lessonIndex + 1 < lessons.length) {
          lessons[lessonIndex + 1] = lessons[lessonIndex + 1].copyWith(isUnlocked: true);
        }
      }
    });

    await _saveLessonProgress();

    final completedRegularLessons = lessons.where((l) => l.isCompleted && l.type == LessonNodeType.lesson).length;
    
    if (AdaptiveExerciseService.shouldUnlockAdaptiveExercises(completedRegularLessons)) {
      await _generateSpecialNodes();
      setState(() {});
      _showSpecialNodesUnlockedMessage(completedRegularLessons);
    }

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

  // MENSAJES Y DIÁLOGOS
  void _showSpecialNodesUnlockedMessage(int completedLessons) {
    final levelNumber = (completedLessons / 5).floor();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.celebration, color: AppColors.secondary, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                '🎉 ¡Felicidades!',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Has completado $completedLessons lecciones y has desbloqueado:',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videogame_asset, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🎮 Rescate en las Alturas $levelNumber',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🧠 Nivel Adaptativo $levelNumber',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '¡Continuar!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextLessonMessage(int completedLessonId) {
    final currentIndex = lessons.indexWhere((lesson) => lesson.id == completedLessonId);
    if (currentIndex != -1 && currentIndex + 1 < lessons.length) {
      return 'Se desbloqueó: ${lessons[currentIndex + 1].title}';
    }
    return '¡Has completado todas las lecciones disponibles!';
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

  // UI HELPERS
  Color _getNodeColor(LessonNode lesson) {
    if (lesson.isCompleted) return AppColors.success;
    if (lesson.isUnlocked) {
      switch (lesson.type) {
        case LessonNodeType.lesson: return AppColors.primary;
        case LessonNodeType.game: return AppColors.secondary;
        case LessonNodeType.adaptive: return AppColors.info;
      }
    }
    return Colors.grey.shade400;
  }

  Color _getNodeBorderColor(LessonNode lesson) {
    if (lesson.isCompleted) return AppColors.success.withOpacity(0.8);
    if (lesson.isUnlocked) {
      switch (lesson.type) {
        case LessonNodeType.lesson: return AppColors.primary.withOpacity(0.8);
        case LessonNodeType.game: return AppColors.secondary.withOpacity(0.8);
        case LessonNodeType.adaptive: return AppColors.info.withOpacity(0.8);
      }
    }
    return Colors.grey.shade500;
  }

  Color _getNodeIconColor(LessonNode lesson) {
    if (lesson.isCompleted || lesson.isUnlocked) return Colors.white;
    return Colors.grey.shade600;
  }

  IconData _getNodeIcon(LessonNode lesson) {
    switch (lesson.type) {
      case LessonNodeType.game: return Icons.videogame_asset;
      case LessonNodeType.adaptive: return Icons.psychology;
      case LessonNodeType.lesson: return Icons.school;
    }
  }

  // BUILD METHODS
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
        body: _buildErrorState(),
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
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSubjectHeader()),
            SliverToBoxAdapter(child: _buildLessonsPath()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            label: Text('Reintentar', style: TextStyle(fontFamily: 'Comic Sans MS')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectHeader() {
    final completedCount = lessons.where((l) => l.isCompleted).length;
    final totalCount = lessons.length;
    final regularLessonsCompleted = lessons.where((l) => l.isCompleted && l.type == LessonNodeType.lesson).length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.school, '$completedCount/$totalCount', 'Completadas', AppColors.primary),
              _buildStatItem(Icons.trending_up, '${(progress * 100).round()}%', 'Progreso', AppColors.success),
              _buildStatItem(Icons.psychology, '${(regularLessonsCompleted / 5).floor()}', 'Adaptativos', AppColors.secondary),
            ],
          ),
          const SizedBox(height: 24),
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

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
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
          onTap: () => _handleLessonTap(lesson),
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
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
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
}