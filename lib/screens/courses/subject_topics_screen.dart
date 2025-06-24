// lib/screens/courses/subject_topics_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/screens/screen_base.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../config/routes.dart';
import '../../models/lesson_models.dart';
import '../../services/topic_lesson_service.dart';
import '../../services/graphql_service.dart';

class SubjectTopicsScreen extends StatefulWidget {
  final dynamic subject;

  const SubjectTopicsScreen({super.key, required this.subject});

  @override
  State<SubjectTopicsScreen> createState() => _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends State<SubjectTopicsScreen> {
  late TopicLessonService _topicLessonService;
  List<Topic> topics = [];
  Map<int, bool> topicCompletionStatus = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadTopicsFromBackend();
  }

  void _initializeService() async {
    final client = await GraphQLService.getClient();
    _topicLessonService = TopicLessonService(client);
  }

  Future<void> _loadTopicsFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final subjectData = await _topicLessonService.getSubjectTopics(widget.subject.id.toString());
      final topicsData = (subjectData['topics'] as List).map((topicJson) => Topic.fromJson(topicJson)).toList();
      
      topics = topicsData;
      await _loadTopicProgress();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadTopicProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final topic in topics) {
        final topicKey = 'topic_${topic.id}_completed';
        topicCompletionStatus[topic.id] = prefs.getBool(topicKey) ?? false;
      }
    } catch (e) {
      print('Error cargando progreso de topics: $e');
    }
  }

  Future<void> _markTopicAsCompleted(int topicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topicKey = 'topic_${topicId}_completed';
      await prefs.setBool(topicKey, true);
      
      setState(() {
        topicCompletionStatus[topicId] = true;
      });
    } catch (e) {
      print('Error guardando progreso del topic: $e');
    }
  }

  void _navigateToTopicLessons(Topic topic) {
    Navigator.pushNamed(
      context,
      AppRoutes.subjectLessons,
      arguments: {
        'subject': widget.subject,
        'topic': topic,
        'onTopicCompleted': () => _markTopicAsCompleted(topic.id),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ScreenBase.forStudent(
        title: widget.subject.name,
        showBackButton: true,
        isLoading: true,
        loadingMessage: 'Cargando temas...',
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
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTopicCard(topics[index]),
                  childCount: topics.length,
                ),
              ),
            ),
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
          const SizedBox(height: 16),
          Text(
            'Error al cargar los temas',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTopicsFromBackend,
            icon: const Icon(Icons.refresh),
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
    );
  }

  Widget _buildHeader() {
    final completedTopics = topicCompletionStatus.values.where((completed) => completed).length;
    final totalTopics = topics.length;
    final progress = totalTopics > 0 ? completedTopics / totalTopics : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona un tema',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa las lecciones de cada tema para desbloquear contenido especial',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.topic,
                '$completedTopics/$totalTopics',
                'Temas completados',
                AppColors.success,
              ),
              _buildStatItem(
                Icons.trending_up,
                '${(progress * 100).round()}%',
                'Progreso total',
                AppColors.primary,
              ),
              _buildStatItem(
                Icons.school,
                '${topics.fold(0, (sum, topic) => sum + topic.lessons.length)}',
                'Lecciones totales',
                AppColors.secondary,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
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

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
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
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopicCard(Topic topic) {
    final isCompleted = topicCompletionStatus[topic.id] ?? false;
    
    return BounceAnimation(
      child: GestureDetector(
        onTap: () => _navigateToTopicLessons(topic),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                  : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono y estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Título del tema
                    Expanded(
                      child: Text(
                        topic.name,
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Información del tema
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.lessons.length} lecciones',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${topic.xpReward} XP',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Efecto de brillo
              if (!isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
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
}