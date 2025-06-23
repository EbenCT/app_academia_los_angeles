// lib/models/progress_models.dart
// CORREGIDO: Compatible con la estructura existente de StudentExerciseProgress

import '../models/lesson_models.dart';

/// Modelo para el progreso de lecciones (GraphQL compatible)
class LessonProgress {
  final int id;
  final int studentId;
  final int lessonId;
  final bool isCompleted;
  final bool isUnlocked;
  final int attempts;
  final double? bestScore;
  final int timeSpent; // en segundos
  final DateTime? lastAttemptAt;
  final DateTime? completedAt;
  final Lesson? lesson; // Información de la lección (opcional)

  LessonProgress({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.isCompleted,
    required this.isUnlocked,
    this.attempts = 0,
    this.bestScore,
    this.timeSpent = 0,
    this.lastAttemptAt,
    this.completedAt,
    this.lesson,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      lessonId: json['lessonId'] ?? json['lesson_id'] ?? 0,
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      isUnlocked: json['isUnlocked'] ?? json['is_unlocked'] ?? false,
      attempts: json['attempts'] ?? 0,
      bestScore: json['bestScore']?.toDouble() ?? json['best_score']?.toDouble(),
      timeSpent: json['timeSpent'] ?? json['time_spent'] ?? 0,
      lastAttemptAt: json['lastAttemptAt'] != null 
          ? DateTime.parse(json['lastAttemptAt'])
          : json['last_attempt_at'] != null
              ? DateTime.parse(json['last_attempt_at'])
              : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      lesson: json['lesson'] != null ? Lesson.fromJson(json['lesson']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'attempts': attempts,
      'bestScore': bestScore,
      'timeSpent': timeSpent,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      if (lesson != null) 'lesson': lesson!.toJson(),
    };
  }

  LessonProgress copyWith({
    int? id,
    int? studentId,
    int? lessonId,
    bool? isCompleted,
    bool? isUnlocked,
    int? attempts,
    double? bestScore,
    int? timeSpent,
    DateTime? lastAttemptAt,
    DateTime? completedAt,
    Lesson? lesson,
  }) {
    return LessonProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      attempts: attempts ?? this.attempts,
      bestScore: bestScore ?? this.bestScore,
      timeSpent: timeSpent ?? this.timeSpent,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      completedAt: completedAt ?? this.completedAt,
      lesson: lesson ?? this.lesson,
    );
  }
}

/// Modelo para el progreso de ejercicios (GraphQL compatible)
class ExerciseProgress {
  final int id;
  final int studentId;
  final int exerciseId;
  final int attempts;
  final bool isCorrect;
  final int timeSpent; // en segundos
  final int? selectedOptionId;
  final DateTime completedAt;
  final Exercise? exercise; // Información del ejercicio (opcional)

  ExerciseProgress({
    required this.id,
    required this.studentId,
    required this.exerciseId,
    required this.attempts,
    required this.isCorrect,
    required this.timeSpent,
    this.selectedOptionId,
    required this.completedAt,
    this.exercise,
  });

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      exerciseId: json['exerciseId'] ?? json['exercise_id'] ?? 0,
      attempts: json['attempts'] ?? 1,
      isCorrect: json['isCorrect'] ?? json['is_correct'] ?? false,
      timeSpent: json['timeSpent'] ?? json['time_spent'] ?? 0,
      selectedOptionId: json['selectedOptionId'] ?? json['selected_option_id'],
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : DateTime.now(),
      exercise: json['exercise'] != null ? Exercise.fromJson(json['exercise']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'exerciseId': exerciseId,
      'attempts': attempts,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'selectedOptionId': selectedOptionId,
      'completedAt': completedAt.toIso8601String(),
      if (exercise != null) 'exercise': exercise!.toJson(),
    };
  }
}

/// Extensión para convertir tu StudentExerciseProgress existente a GraphQL
extension StudentExerciseProgressExtension on StudentExerciseProgress {
  /// Convertir a formato compatible con GraphQL
  Map<String, dynamic> toGraphQLInput() {
    final timeSpent = finishedAt != null && startedAt != null 
        ? finishedAt!.difference(startedAt!).inSeconds 
        : 30; // default 30 segundos

    return {
      'studentId': studentId,
      'exerciseId': exerciseId,
      'isCorrect': !error, // error = false significa correcto
      'timeSpent': timeSpent,
      'selectedOptionId': null, // No está en tu modelo actual
      'attempts': 1, // Default 1 intento
    };
  }

  /// Crear progreso con campos adicionales para GraphQL
  StudentExerciseProgressExtended toExtended({
    int? timeSpent,
    int? selectedOptionId,
    int? attempts,
  }) {
    final calculatedTimeSpent = timeSpent ?? 
        (finishedAt != null && startedAt != null 
            ? finishedAt!.difference(startedAt!).inSeconds 
            : 30);
    
    return StudentExerciseProgressExtended(
      id: id,
      studentId: studentId,
      exerciseId: exerciseId,
      startedAt: startedAt,
      finishedAt: finishedAt,
      error: error,
      timeSpent: calculatedTimeSpent,
      selectedOptionId: selectedOptionId,
      attempts: attempts ?? 1,
    );
  }
}

/// Versión extendida de StudentExerciseProgress para GraphQL
class StudentExerciseProgressExtended extends StudentExerciseProgress {
  final int timeSpent;
  final int? selectedOptionId;
  final int attempts;

  StudentExerciseProgressExtended({
    required super.id,
    required super.studentId,
    required super.exerciseId,
    super.startedAt,
    super.finishedAt,
    required super.error,
    required this.timeSpent,
    this.selectedOptionId,
    this.attempts = 1,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson.addAll({
      'timeSpent': timeSpent,
      'selectedOptionId': selectedOptionId,
      'attempts': attempts,
    });
    return baseJson;
  }

  /// Para GraphQL mutations
  Map<String, dynamic> toGraphQLInput() {
    return {
      'studentId': studentId,
      'exerciseId': exerciseId,
      'isCorrect': !error,
      'timeSpent': timeSpent,
      'selectedOptionId': selectedOptionId,
      'attempts': attempts,
    };
  }
}

/// Modelo para estadísticas de materia
class SubjectStats {
  final int totalLessons;
  final int completedLessons;
  final int totalExercises;
  final int correctExercises;
  final int totalTimeSpent; // en segundos
  final double averageScore;
  final int streakDays;
  final DateTime? lastActivity;
  final double progressPercentage;

  SubjectStats({
    required this.totalLessons,
    required this.completedLessons,
    required this.totalExercises,
    required this.correctExercises,
    required this.totalTimeSpent,
    required this.averageScore,
    required this.streakDays,
    this.lastActivity,
    required this.progressPercentage,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) {
    return SubjectStats(
      totalLessons: json['totalLessons'] ?? json['total_lessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? json['completed_lessons'] ?? 0,
      totalExercises: json['totalExercises'] ?? json['total_exercises'] ?? 0,
      correctExercises: json['correctExercises'] ?? json['correct_exercises'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? json['total_time_spent'] ?? 0,
      averageScore: (json['averageScore'] ?? json['average_score'] ?? 0.0).toDouble(),
      streakDays: json['streakDays'] ?? json['streak_days'] ?? 0,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity'])
          : json['last_activity'] != null
              ? DateTime.parse(json['last_activity'])
              : null,
      progressPercentage: (json['progressPercentage'] ?? json['progress_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'totalExercises': totalExercises,
      'correctExercises': correctExercises,
      'totalTimeSpent': totalTimeSpent,
      'averageScore': averageScore,
      'streakDays': streakDays,
      'lastActivity': lastActivity?.toIso8601String(),
      'progressPercentage': progressPercentage,
    };
  }

  /// Calcular porcentaje de ejercicios correctos
  double get exerciseAccuracy {
    if (totalExercises == 0) return 0.0;
    return (correctExercises / totalExercises) * 100;
  }

  /// Calcular tiempo promedio por lección (en minutos)
  double get averageTimePerLesson {
    if (completedLessons == 0) return 0.0;
    return (totalTimeSpent / 60) / completedLessons;
  }

  /// Verificar si el estudiante está activo (actividad en los últimos 7 días)
  bool get isActiveStudent {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActivity!).inDays;
    return difference <= 7;
  }
}