// lib/screens/courses/generic_topic_lessons_screen_complete.dart
// Pantalla COMPLETA actualizada para usar GraphQL con fallback local

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_models.dart';
import '../../adapters/lesson_screen_adapter.dart';
import '../../providers/student_provider.dart';
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
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Inicializar migración y cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  /// Inicializar pantalla con migración automática
  Future<void> _initializeScreen() async {
    // Inicializar migración automática
    await LessonScreenAdapter.initializeForScreen(context);
    
    // Cargar lecciones
    await _loadLessons();
  }

  /// Cargar lecciones usando el adaptador
  Future<void> _loadLessons({bool isRetry = false}) async {
    if (isRetry) {
      setState(() => _isRetrying = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Usar adaptador en lugar de servicio directo
      final lessons = await LessonScreenAdapter.getLessonsWithFallback(widget.topic.id);
      
      // Convertir a LessonNodeData y cargar progreso
      final lessonNodes = <LessonNodeData>[];
      
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        
        // Obtener progreso híbrido
        final progressData = await LessonScreenAdapter.getProgressForUI(
          context, 
          widget.subject.id,
        );
        
        // Determinar si está desbloqueada/completada
        bool isUnlocked = i == 0; // Primera siempre desbloqueada
        bool isCompleted = false;
        
        // Lógica de progreso (adaptada del código original)
        if (i > 0 && lessonNodes.isNotEmpty) {
          isUnlocked = lessonNodes[i - 1].isCompleted;
        }
        
        lessonNodes.add(LessonNodeData(
          id: lesson.id,
          title: lesson.title,
          type: i % 2 == 0 ? LessonNodeType.lesson : LessonNodeType.game,
          isUnlocked: isUnlocked,
          isCompleted: isCompleted,
          description: lesson.content,
          progressPercentage: progressData['percentage']?.toDouble() ?? 0.0,
        ));
      }

      setState(() {
        _lessonNodes = lessonNodes;
        _isLoading = false;
        _isRetrying = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isRetrying = false;
      });
    }
  }

  /// Manejar compleción de lección
  Future<void> _onLessonCompleted(int lessonId, int index) async {
    try {
      // Usar adaptador para guardar progreso
      await LessonScreenAdapter.completeLessonWithSync(
        context,
        lessonId,
        timeSpent: 300, // 5 minutos ejemplo
        score: 85.0,
        subjectId: widget.subject.id,
      );

      // Actualizar UI local
      setState(() {
        // Marcar como completada
        _lessonNodes[index] = _lessonNodes[index].copyWith(isCompleted: true);
        
        // Desbloquear la siguiente si existe
        if (index + 1 < _lessonNodes.length) {
          _lessonNodes[index + 1] = _lessonNodes[index + 1].copyWith(isUnlocked: true);
        }
      });

      // Mostrar feedback positivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('¡Lección completada!'),
                const Spacer(),
                // Mostrar estado de sincronización
                LessonScreenAdapter.buildConnectionStatus(),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardando progreso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      title: widget.topic.name,
      body: Column(
        children: [
          // Header con información del tema e indicador de conexión
          _buildTopicHeader(),
          
          // Contenido principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Construir header del tema
  Widget _buildTopicHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.topic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Indicador de estado de conexión
          LessonScreenAdapter.buildConnectionStatus(),
        ],
      ),
    );
  }

  /// Construir contenido principal
  Widget _buildContent() {
    if (_isLoading) {
      return LessonScreenAdapter.buildLoadingWidget(
        message: 'Cargando lecciones...',
      );
    }

    if (_errorMessage != null) {
      return LessonScreenAdapter.buildErrorWidget(
        _errorMessage!,
        () => _loadLessons(isRetry: true),
        showRetry: !_isRetrying,
      );
    }

    if (_lessonNodes.isEmpty) {
      return const Center(
        child: Text('No hay lecciones disponibles para este tema'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadLessons(isRetry: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lessonNodes.length,
        itemBuilder: (context, index) {
          return _buildLessonNode(index);
        },
      ),
    );
  }

  /// Construir nodo de lección
  Widget _buildLessonNode(int index) {
    final node = _lessonNodes[index];
    final isEven = index % 2 == 0;

    return FadeAnimation(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(
          bottom: 20,
          left: isEven ? 0 : 50,
          right: isEven ? 50 : 0,
        ),
        child: GestureDetector(
          onTap: node.isUnlocked ? () => _onLessonTap(node, index) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: node.isUnlocked ? Colors.white : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: node.isCompleted 
                    ? Colors.green 
                    : node.isUnlocked 
                        ? AppColors.primary 
                        : Colors.grey,
                width: 2,
              ),
              boxShadow: node.isUnlocked
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icono del tipo de lección
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: node.isCompleted
                        ? Colors.green
                        : node.isUnlocked
                            ? (node.type == LessonNodeType.game 
                                ? Colors.orange 
                                : AppColors.primary)
                            : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    node.isCompleted
                        ? Icons.check
                        : node.type == LessonNodeType.game
                            ? Icons.videogame_asset
                            : Icons.book,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información de la lección
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: node.isUnlocked ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      if (node.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          node.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: node.isUnlocked ? Colors.grey[600] : Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Mostrar progreso si disponible
                      if (node.progressPercentage > 0) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: node.progressPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            node.isCompleted ? Colors.green : AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Estado visual
                if (!node.isUnlocked)
                  const Icon(Icons.lock, color: Colors.grey)
                else if (node.isCompleted)
                  const Icon(Icons.star, color: Colors.amber)
                else
                  Icon(Icons.arrow_forward_ios, 
                       color: AppColors.primary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Manejar tap en lección
  void _onLessonTap(LessonNodeData node, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericLessonScreen(
          lessonId: node.id,
          lessonTitle: node.title,
          onLessonCompleted: () => _onLessonCompleted(node.id, index),
        ),
      ),
    );
  }
}