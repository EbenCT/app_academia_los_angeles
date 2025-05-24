// lib/screens/courses/subject_lessons_screen.dart (con persistencia)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Método para crear una copia con cambios
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
  final dynamic subject;

  const SubjectLessonsScreen({super.key, required this.subject});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  late List<LessonNode> lessons;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLessons();
  }

  Future<void> _initializeLessons() async {
    setState(() {
      _isLoading = true;
    });

    // Crear lecciones base
    final baseLessons = [
      LessonNode(
        id: 1,
        title: 'Introducción a los números enteros',
        type: LessonType.lesson,
        isUnlocked: true, // La primera siempre está desbloqueada
        isCompleted: false,
        description: 'Aprende qué son los números enteros',
      ),
      LessonNode(
        id: 2,
        title: 'Rescate de alturas',
        type: LessonType.game,
        isUnlocked: false,
        isCompleted: false,
        description: 'Practica con números enteros en un juego divertido',
      ),
      // Puedes agregar más lecciones aquí
      LessonNode(
        id: 3,
        title: 'Operaciones con enteros',
        type: LessonType.lesson,
        isUnlocked: false,
        isCompleted: false,
        description: 'Suma y resta de números enteros',
      ),
      LessonNode(
        id: 4,
        title: 'Batalla matemática',
        type: LessonType.game,
        isUnlocked: false,
        isCompleted: false,
        description: 'Demuestra tu dominio de los números enteros',
      ),
    ];

    // Cargar progreso guardado
    await _loadLessonProgress(baseLessons);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLessonProgress(List<LessonNode> baseLessons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons';
      final progressJson = prefs.getStringList(subjectKey) ?? [];

      if (progressJson.isNotEmpty) {
        // Cargar progreso guardado
        final savedLessons = progressJson.map((lessonString) {
          final parts = lessonString.split('|');
          if (parts.length >= 4) {
            return LessonNode(
              id: int.parse(parts[0]),
              title: parts[1],
              type: parts[2] == 'LessonType.game' ? LessonType.game : LessonType.lesson,
              isUnlocked: parts[3] == 'true',
              isCompleted: parts[4] == 'true',
              description: parts.length > 5 ? parts[5] : null,
            );
          }
          return null;
        }).where((lesson) => lesson != null).cast<LessonNode>().toList();

        // Combinar con lecciones base, manteniendo el progreso
        lessons = baseLessons.map((baseLesson) {
          final savedLesson = savedLessons.firstWhere(
            (saved) => saved.id == baseLesson.id,
            orElse: () => baseLesson,
          );
          return baseLesson.copyWith(
            isUnlocked: savedLesson.isUnlocked,
            isCompleted: savedLesson.isCompleted,
          );
        }).toList();

        print('Progreso de lecciones cargado para materia ${widget.subject.name}');
      } else {
        // No hay progreso guardado, usar lecciones base
        lessons = baseLessons;
        print('Usando lecciones base para materia ${widget.subject.name}');
      }
    } catch (e) {
      print('Error cargando progreso de lecciones: $e');
      lessons = baseLessons;
    }
  }

  Future<void> _saveLessonProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${widget.subject.id}_lessons';
      
      final progressStrings = lessons.map((lesson) {
        return '${lesson.id}|${lesson.title}|${lesson.type}|${lesson.isUnlocked}|${lesson.isCompleted}|${lesson.description ?? ''}';
      }).toList();
      
      await prefs.setStringList(subjectKey, progressStrings);
      print('Progreso de lecciones guardado para materia ${widget.subject.name}');
    } catch (e) {
      print('Error guardando progreso de lecciones: $e');
    }
  }

  void _completeLessonNode(int lessonId) async {
    setState(() {
      // Marcar la lección como completada
      final lessonIndex = lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (lessonIndex != -1) {
        lessons[lessonIndex] = lessons[lessonIndex].copyWith(isCompleted: true);
        
        // Desbloquear la siguiente lección
        if (lessonIndex + 1 < lessons.length) {
          lessons[lessonIndex + 1] = lessons[lessonIndex + 1].copyWith(isUnlocked: true);
        }
      }
    });

    // Guardar progreso
    await _saveLessonProgress();

    // Mostrar mensaje de éxito
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
          // Estadísticas de progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressStat(
                'Completadas',
                '${lessons.where((l) => l.isCompleted).length}',
                '${lessons.length}',
                AppColors.success,
                Icons.check_circle,
              ),
              _buildProgressStat(
                'Disponibles',
                '${lessons.where((l) => l.isUnlocked).length}',
                '${lessons.length}',
                AppColors.primary,
                Icons.lock_open,
              ),
              _buildProgressStat(
                'Progreso',
                '${((lessons.where((l) => l.isCompleted).length / lessons.length) * 100).round()}%',
                '',
                AppColors.accent,
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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

  Widget _buildProgressStat(String label, String value, String total, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          total.isNotEmpty ? '$value/$total' : value,
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
          onTap: lesson.isUnlocked ? () => _handleLessonTap(lesson) : () => _showLockedMessage(),
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

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Completa la lección anterior para desbloquear esta',
          style: TextStyle(fontFamily: 'Comic Sans MS'),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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