
import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../adapters/lesson_screen_adapter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/screens/screen_base.dart';
import 'generic_topic_lessons_screen.dart';

/// Tipo de lección en el mapa
enum LessonType { lesson, game }

/// Modelo para representar una lección en la UI
class LessonNode {
  final int id;
  final String title;
  final LessonType type;
  final bool isUnlocked;
  final bool isCompleted;
  final String? description;

  LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.isUnlocked,
    required this.isCompleted,
    this.description,
  });

  LessonNode copyWith({
    int? id,
    String? title,
    LessonType? type,
    bool? isUnlocked,
    bool? isCompleted,
    String? description,
  }) {
    return LessonNode(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
    );
  }

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'description': description,
    };
  }

  // Crear desde Map
  factory LessonNode.fromMap(Map<String, dynamic> map) {
    return LessonNode(
      id: map['id'],
      title: map['title'],
      type: LessonType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => LessonType.lesson,
      ),
      isUnlocked: map['isUnlocked'],
      isCompleted: map['isCompleted'],
      description: map['description'],
    );
  }
}

class SubjectLessonsScreen extends StatefulWidget {
  final Subject subject;

  const SubjectLessonsScreen({super.key, required this.subject});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  List<Topic> _topics = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _progressData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  /// Inicializar pantalla con migración automática
  Future<void> _initializeScreen() async {
    // Inicializar migración automática
    await LessonScreenAdapter.initializeForScreen(context);
    
    // Cargar datos
    await _loadTopicsAndProgress();
  }

  /// Cargar temas y progreso usando el adaptador
  Future<void> _loadTopicsAndProgress({bool isRetry = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener temas usando el adaptador
      final topics = await LessonScreenAdapter.getTopicsWithFallback(widget.subject.id);
      
      // Obtener progreso híbrido
      final progressData = await LessonScreenAdapter.getProgressForUI(
        context, 
        widget.subject.id,
      );

      setState(() {
        _topics = topics;
        _progressData = progressData;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      title: widget.subject.name,
      body: Column(
        children: [
          // Header con información de la materia
          _buildSubjectHeader(),
          
          // Contenido principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Construir header de la materia
  Widget _buildSubjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.code,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subject.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subject.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  ],
                ),
              ),
              // Indicador de estado de conexión
              LessonScreenAdapter.buildConnectionStatus(),
            ],
          ),
          
          // Mostrar progreso si está disponible
          if (_progressData != null) ...[
            const SizedBox(height: 16),
            _buildProgressIndicator(),
          ],
        ],
      ),
    );
  }

  /// Construir indicador de progreso
  Widget _buildProgressIndicator() {
    final progress = _progressData!;
    final percentage = progress['percentage'] ?? 0;
    final completed = progress['completed'] ?? 0;
    final total = progress['total'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '$completed/$total temas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage% completado',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir contenido principal
  Widget _buildContent() {
    if (_isLoading) {
      return LessonScreenAdapter.buildLoadingWidget(
        message: 'Cargando temas...',
      );
    }

    if (_errorMessage != null) {
      return LessonScreenAdapter.buildErrorWidget(
        _errorMessage!,
        () => _loadTopicsAndProgress(isRetry: true),
      );
    }

    if (_topics.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay temas disponibles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los temas se agregarán pronto',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTopicsAndProgress(isRetry: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          return _buildTopicCard(index);
        },
      ),
    );
  }

  /// Construir tarjeta de tema
  Widget _buildTopicCard(int index) {
    final topic = _topics[index];
    final isUnlocked = index == 0 || _isTopicUnlocked(index);

    return FadeAnimation(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: isUnlocked ? () => _onTopicTap(topic) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isUnlocked ? AppColors.primary : Colors.grey,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icono del tema
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.primary : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked ? Icons.play_arrow : Icons.lock,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del tema
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.xpReward} XP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Flecha de navegación
                if (isUnlocked)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Verificar si un tema está desbloqueado
  bool _isTopicUnlocked(int index) {
    // Lógica simple: el primer tema siempre está desbloqueado
    // Los demás se desbloquean cuando el anterior se completa
    // Por ahora, todos están desbloqueados para testing
    return true; // Cambiar según tu lógica de negocio
  }

  /// Manejar tap en tema
  void _onTopicTap(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericTopicLessonsScreen(
          topic: topic,
          subject: widget.subject,
        ),
      ),
    ).then((_) {
      // Recargar progreso cuando se regrese de las lecciones
      _loadTopicsAndProgress();
    });
  }
}