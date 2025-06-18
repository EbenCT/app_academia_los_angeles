// lib/screens/courses/generic_topic_lessons_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/lesson_models.dart';
import '../../services/lesson_api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/screens/screen_base.dart';
import '../game/generic_lesson_screen.dart';

/// Tipo de nodo en el mapa de lecciones
enum LessonNodeType { lesson, game }

/// Representación visual de una lección en el mapa
class LessonNodeData {
  final int id;
  final String title;
  final LessonNodeType type;
  final bool isUnlocked;
  final bool isCompleted;
  final String? description;
  final double progressPercentage;

  LessonNodeData({
    required this.id,
    required this.title,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    this.description,
    this.progressPercentage = 0.0,
  });

  LessonNodeData copyWith({
    int? id,
    String? title,
    LessonNodeType? type,
    bool? isUnlocked,
    bool? isCompleted,
    String? description,
    double? progressPercentage,
  }) {
    return LessonNodeData(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

class GenericTopicLessonsScreen extends StatefulWidget {
  final Topic topic;
  final Subject subject;

  const GenericTopicLessonsScreen({
    super.key,
    required this.topic,
    required this.subject,
  });

  @override
  State<GenericTopicLessonsScreen> createState() => _GenericTopicLessonsScreenState();
}

class _GenericTopicLessonsScreenState extends State<GenericTopicLessonsScreen> {
  List<LessonNodeData> _lessonNodes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentStudentId = 1; // TODO: Obtener del usuario logueado

  @override
  void initState() {
    super.initState();
    _loadLessonsAndProgress();
  }

  Future<void> _loadLessonsAndProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar lecciones del backend
      final lessons = await LessonApiService.getLessonsByTopic(widget.topic.id);
      
      // Cargar progreso del estudiante
      final progressList = await LessonApiService.getLessonProgress(
        _currentStudentId, 
        widget.topic.id,
      );

      // Combinar lecciones con progreso
      final lessonNodes = <LessonNodeData>[];
      
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        final progress = progressList.firstWhere(
          (p) => p.lessonId == lesson.id,
          orElse: () => LessonProgress(
            lessonId: lesson.id,
            isUnlocked: i == 0, // Solo la primera está desbloqueada por defecto
            isCompleted: false,
          ),
        );

        // Determinar tipo de lección (puedes agregar lógica aquí)
        final type = _determineLessonType(lesson, i);

        lessonNodes.add(LessonNodeData(
          id: lesson.id,
          title: lesson.title,
          type: type,
          isUnlocked: progress.isUnlocked,
          isCompleted: progress.isCompleted,
          description: lesson.content,
          progressPercentage: progress.progressPercentage,
        ));
      }

      setState(() {
        _lessonNodes = lessonNodes;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  LessonNodeType _determineLessonType(Lesson lesson, int index) {
    // Lógica para determinar si es una lección normal o un juego
    // Por ejemplo, las lecciones pares podrían ser juegos
    if (index % 2 == 1) {
      return LessonNodeType.game;
    }
    return LessonNodeType.lesson;
  }

  Future<void> _onLessonCompleted(int lessonId) async {
    setState(() {
      // Marcar lección como completada
      final lessonIndex = _lessonNodes.indexWhere((node) => node.id == lessonId);
      if (lessonIndex != -1) {
        _lessonNodes[lessonIndex] = _lessonNodes[lessonIndex].copyWith(
          isCompleted: true,
          progressPercentage: 100.0,
        );

        // Desbloquear siguiente lección
        if (lessonIndex + 1 < _lessonNodes.length) {
          _lessonNodes[lessonIndex + 1] = _lessonNodes[lessonIndex + 1].copyWith(
            isUnlocked: true,
          );
        }
      }
    });

    // Guardar progreso localmente también
    await _saveProgressLocally();

    // Mostrar mensaje de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Lección completada! +${widget.topic.xpReward} XP'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveProgressLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topicKey = 'topic_${widget.topic.id}_progress';
      
      final progressData = _lessonNodes.map((node) {
        return '${node.id}|${node.isUnlocked}|${node.isCompleted}|${node.progressPercentage}';
      }).toList();
      
      await prefs.setStringList(topicKey, progressData);
    } catch (e) {
      print('Error guardando progreso localmente: $e');
    }
  }

  void _onLessonTap(LessonNodeData node) {
    if (!node.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes completar las lecciones anteriores primero'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Navegar a la lección genérica
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericLessonScreen(
          lessonId: node.id,
          lessonTitle: node.title,
          onLessonCompleted: () => _onLessonCompleted(node.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase.forStudent(
      title: widget.topic.name,
      showBackButton: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: LoadingIndicator(
          message: 'Cargando lecciones...',
          useAstronaut: true,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_lessonNodes.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildLessonMap();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar las lecciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadLessonsAndProgress,
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay lecciones disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pronto habrá contenido nuevo para este tema',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonMap() {
    return Container(
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
          // Header con información del tema
          SliverToBoxAdapter(
            child: _buildTopicHeader(),
          ),
          
          // Lista de lecciones estilo mapa
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final node = _lessonNodes[index];
                  return FadeAnimation(
                    delay: Duration(milliseconds: 200 * index),
                    child: _buildLessonNode(node, index),
                  );
                },
                childCount: _lessonNodes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicHeader() {
    final completedCount = _lessonNodes.where((node) => node.isCompleted).length;
    final totalCount = _lessonNodes.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.topic.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 8),
          
          Text(
            '$completedCount de $totalCount lecciones completadas',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          
          if (progress == 1.0)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '¡Tema completado! +${widget.topic.xpReward} XP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonNode(LessonNodeData node, int index) {
    final isLeft = index % 2 == 0;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          if (!isLeft) Expanded(child: SizedBox()),
          
          // Línea conectora (para nodos que no son el primero)
          if (index > 0)
            Container(
              width: 2,
              height: 40,
              color: node.isUnlocked ? AppColors.primary : Colors.grey[300],
              margin: EdgeInsets.only(right: isLeft ? 15 : 0, left: isLeft ? 0 : 15),
            ),
          
          // Nodo de la lección
          GestureDetector(
            onTap: () => _onLessonTap(node),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getNodeColor(node),
                border: Border.all(
                  color: node.isUnlocked ? AppColors.primary : Colors.grey,
                  width: 3,
                ),
                boxShadow: node.isUnlocked ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Icon(
                _getNodeIcon(node),
                color: Colors.white,
                size: node.type == LessonNodeType.game ? 28 : 24,
              ),
            ),
          ),
          
          SizedBox(width: 15),
          
          // Información de la lección
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: node.isUnlocked ? AppColors.primary.withOpacity(0.3) : Colors.grey[300]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: node.isUnlocked ? AppColors.textPrimary : Colors.grey,
                    ),
                  ),
                  if (node.description != null) ...[
                    SizedBox(height: 4),
                    Text(
                      node.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (node.isCompleted)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Completada',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (isLeft) Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Color _getNodeColor(LessonNodeData node) {
    if (node.isCompleted) return AppColors.success;
    if (node.isUnlocked) return AppColors.primary;
    return Colors.grey;
  }

  IconData _getNodeIcon(LessonNodeData node) {
    if (node.isCompleted) return Icons.check;
    if (node.type == LessonNodeType.game) return Icons.videogame_asset;
    return Icons.school;
  }
}