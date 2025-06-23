// lib/graphql/lesson_queries.dart

/// Queries GraphQL para el manejo de lecciones
class LessonQueries {
  
  /// Query para obtener todos los temas de una materia con sus lecciones básicas
  static const String getTopicsBySubject = r'''
  query GetTopicsBySubject($subjectId: Int!) {
    topicsBySubject(subjectId: $subjectId) {
      id
      name
      xpReward
      subjectId
      lessons {
        id
        title
        content
        imgLink
        topicId
        order
        isActive
      }
    }
  }
  ''';

  /// Query para obtener lecciones detalladas de un tema específico
  static const String getLessonsByTopic = r'''
  query GetLessonsByTopic($topicId: Int!) {
    lessonsByTopic(topicId: $topicId) {
      id
      title
      content
      imgLink
      topicId
      order
      isActive
      estimatedTime
      difficulty
      objectives
    }
  }
  ''';

  /// Query para obtener una lección completa con ejercicios
  static const String getLessonWithExercises = r'''
  query GetLessonWithExercises($lessonId: Int!) {
    lesson(id: $lessonId) {
      id
      title
      content
      imgLink
      topicId
      order
      isActive
      estimatedTime
      difficulty
      objectives
      exercises {
        id
        severity
        question
        type
        coins
        lessonId
        order
        timeLimit
        options {
          id
          text
          isCorrect
          order
          exerciseId
          explanation
        }
      }
    }
  }
  ''';

  /// Query para obtener el progreso del estudiante en un tema
  static const String getLessonProgress = r'''
  query GetLessonProgress($studentId: Int!, $topicId: Int!) {
    lessonProgress(studentId: $studentId, topicId: $topicId) {
      id
      studentId
      lessonId
      isCompleted
      isUnlocked
      attempts
      bestScore
      timeSpent
      lastAttemptAt
      completedAt
      lesson {
        id
        title
        topicId
      }
    }
  }
  ''';

  /// Query para obtener el progreso de ejercicios específicos
  static const String getExerciseProgress = r'''
  query GetExerciseProgress($studentId: Int!, $lessonId: Int!) {
    exerciseProgress(studentId: $studentId, lessonId: $lessonId) {
      id
      studentId
      exerciseId
      attempts
      isCorrect
      timeSpent
      selectedOptionId
      completedAt
      exercise {
        id
        question
        type
        lessonId
      }
    }
  }
  ''';

  /// Mutation para actualizar progreso de lección
  static const String updateLessonProgress = r'''
  mutation UpdateLessonProgress($input: LessonProgressInput!) {
    updateLessonProgress(input: $input) {
      id
      studentId
      lessonId
      isCompleted
      isUnlocked
      attempts
      bestScore
      timeSpent
      completedAt
    }
  }
  ''';

  /// Mutation para guardar progreso de ejercicio
  static const String saveExerciseProgress = r'''
  mutation SaveExerciseProgress($input: ExerciseProgressInput!) {
    saveExerciseProgress(input: $input) {
      id
      studentId
      exerciseId
      attempts
      isCorrect
      timeSpent
      selectedOptionId
      completedAt
    }
  }
  ''';

  /// Query para obtener estadísticas del estudiante en una materia
  static const String getSubjectStats = r'''
  query GetSubjectStats($studentId: Int!, $subjectId: Int!) {
    subjectStats(studentId: $studentId, subjectId: $subjectId) {
      totalLessons
      completedLessons
      totalExercises
      correctExercises
      totalTimeSpent
      averageScore
      streakDays
      lastActivity
      progressPercentage
    }
  }
  ''';

  /// Query para obtener lecciones recomendadas
  static const String getRecommendedLessons = r'''
  query GetRecommendedLessons($studentId: Int!, $limit: Int = 5) {
    recommendedLessons(studentId: $studentId, limit: $limit) {
      id
      title
      content
      imgLink
      topicId
      difficulty
      estimatedTime
      topic {
        id
        name
        subject {
          id
          name
          code
        }
      }
      progress {
        isCompleted
        isUnlocked
        attempts
        bestScore
      }
    }
  }
  ''';
}

/// Input types para las mutations
class LessonProgressInput {
  final int studentId;
  final int lessonId;
  final bool? isCompleted;
  final bool? isUnlocked;
  final int? attempts;
  final double? bestScore;
  final int? timeSpent;

  LessonProgressInput({
    required this.studentId,
    required this.lessonId,
    this.isCompleted,
    this.isUnlocked,
    this.attempts,
    this.bestScore,
    this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'lessonId': lessonId,
      if (isCompleted != null) 'isCompleted': isCompleted,
      if (isUnlocked != null) 'isUnlocked': isUnlocked,
      if (attempts != null) 'attempts': attempts,
      if (bestScore != null) 'bestScore': bestScore,
      if (timeSpent != null) 'timeSpent': timeSpent,
    };
  }
}

class ExerciseProgressInput {
  final int studentId;
  final int exerciseId;
  final bool isCorrect;
  final int? timeSpent;
  final int? selectedOptionId;
  final int? attempts;

  ExerciseProgressInput({
    required this.studentId,
    required this.exerciseId,
    required this.isCorrect,
    this.timeSpent,
    this.selectedOptionId,
    this.attempts,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'exerciseId': exerciseId,
      'isCorrect': isCorrect,
      if (timeSpent != null) 'timeSpent': timeSpent,
      if (selectedOptionId != null) 'selectedOptionId': selectedOptionId,
      if (attempts != null) 'attempts': attempts,
    };
  }
}