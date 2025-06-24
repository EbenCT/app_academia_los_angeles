// lib/models/adaptive_lesson_models.dart
import 'lesson_models.dart';

/// Lección adaptativa que contiene ejercicios generados dinámicamente
class AdaptiveLesson {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final int requiredCompletedLessons;
  final bool isUnlocked;
  final bool isCompleted;

  AdaptiveLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    required this.requiredCompletedLessons,
    required this.isUnlocked,
    required this.isCompleted,
  });

  AdaptiveLesson copyWith({
    String? id,
    String? title,
    String? description,
    List<Exercise>? exercises,
    int? requiredCompletedLessons,
    bool? isUnlocked,
    bool? isCompleted,
  }) {
    return AdaptiveLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      requiredCompletedLessons: requiredCompletedLessons ?? this.requiredCompletedLessons,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Crea una lección adaptativa a partir de ejercicios del backend
  factory AdaptiveLesson.fromExercises({
    required List<Exercise> exercises,
    required int levelNumber,
    required int requiredCompletedLessons,
    required bool isUnlocked,
    bool isCompleted = false,
  }) {
    return AdaptiveLesson(
      id: 'adaptive_$levelNumber',
      title: 'Nivel Adaptativo $levelNumber',
      description: 'Ejercicios personalizados según tu nivel de conocimiento',
      exercises: exercises,
      requiredCompletedLessons: requiredCompletedLessons,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
    );
  }

  /// Convierte a un objeto Lesson estándar para usar con el sistema existente
  Lesson toStandardLesson() {
    return Lesson(
      id: int.tryParse(id.replaceAll('adaptive_', '')) ?? 0,
      title: title,
      content: description,
      imgLink: null,
      exercises: exercises,
    );
  }
}

/// Tipo de nodo especial en el mapa de lecciones
enum SpecialNodeType {
  game,           // Juego desbloqueado cada 5 lecciones
  adaptive,       // Nivel adaptativo cada 5 lecciones
}

/// Nodo especial que se desbloquea al completar múltiplos de 5 lecciones
class SpecialLessonNode {
  final String id;
  final String title;
  final String description;
  final SpecialNodeType type;
  final int requiredCompletedLessons;
  final bool isUnlocked;
  final bool isCompleted;
  final AdaptiveLesson? adaptiveLesson; // Solo para nodos adaptativos

  SpecialLessonNode({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredCompletedLessons,
    required this.isUnlocked,
    required this.isCompleted,
    this.adaptiveLesson,
  });

  SpecialLessonNode copyWith({
    String? id,
    String? title,
    String? description,
    SpecialNodeType? type,
    int? requiredCompletedLessons,
    bool? isUnlocked,
    bool? isCompleted,
    AdaptiveLesson? adaptiveLesson,
  }) {
    return SpecialLessonNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      requiredCompletedLessons: requiredCompletedLessons ?? this.requiredCompletedLessons,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      adaptiveLesson: adaptiveLesson ?? this.adaptiveLesson,
    );
  }

  /// Crea un nodo de juego especial
  factory SpecialLessonNode.game({
    required int levelNumber,
    required int requiredCompletedLessons,
    required bool isUnlocked,
    bool isCompleted = false,
  }) {
    return SpecialLessonNode(
      id: 'special_game_$levelNumber',
      title: '🎮 Juego Especial $levelNumber',
      description: 'Juego desbloqueado por completar $requiredCompletedLessons lecciones',
      type: SpecialNodeType.game,
      requiredCompletedLessons: requiredCompletedLessons,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
    );
  }

  /// Crea un nodo adaptativo especial
  factory SpecialLessonNode.adaptive({
    required int levelNumber,
    required int requiredCompletedLessons,
    required bool isUnlocked,
    required AdaptiveLesson adaptiveLesson,
    bool isCompleted = false,
  }) {
    return SpecialLessonNode(
      id: 'special_adaptive_$levelNumber',
      title: '🧠 Nivel Adaptativo $levelNumber',
      description: 'Ejercicios personalizados según tu progreso',
      type: SpecialNodeType.adaptive,
      requiredCompletedLessons: requiredCompletedLessons,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      adaptiveLesson: adaptiveLesson,
    );
  }
}