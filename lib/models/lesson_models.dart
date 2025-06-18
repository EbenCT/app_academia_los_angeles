// lib/models/lesson_models.dart

/// Modelo para las materias
class Subject {
  final int id;
  final String code;
  final String name;
  final String description;

  Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
    };
  }
}

/// Modelo para los temas
class Topic {
  final int id;
  final String name;
  final int xpReward;
  final int subjectId;

  Topic({
    required this.id,
    required this.name,
    required this.xpReward,
    required this.subjectId,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      xpReward: json['xp_reward'],
      subjectId: json['subject_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'xp_reward': xpReward,
      'subject_id': subjectId,
    };
  }
}

/// Modelo para las lecciones
class Lesson {
  final int id;
  final String title;
  final String? content;
  final String? imgLink;
  final int topicId;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    this.content,
    this.imgLink,
    required this.topicId,
    this.exercises = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imgLink: json['img_link'],
      topicId: json['topic_id'],
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'img_link': imgLink,
      'topic_id': topicId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para los ejercicios
class Exercise {
  final int id;
  final String severity;
  final String question;
  final int type; // 1 = respuesta correcta, 2 = ordenar opciones
  final int coins;
  final int lessonId;
  final List<ExerciseOption> options;

  Exercise({
    required this.id,
    required this.severity,
    required this.question,
    required this.type,
    required this.coins,
    required this.lessonId,
    this.options = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      severity: json['severity'],
      question: json['question'],
      type: json['type'],
      coins: json['coins'],
      lessonId: json['lesson_id'],
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ExerciseOption.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity,
      'question': question,
      'type': type,
      'coins': coins,
      'lesson_id': lessonId,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para las opciones de ejercicios
class ExerciseOption {
  final int id;
  final String text;
  final bool isCorrect;
  final int index;
  final int exerciseId;

  ExerciseOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.index,
    required this.exerciseId,
  });

  factory ExerciseOption.fromJson(Map<String, dynamic> json) {
    return ExerciseOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
      index: json['index'],
      exerciseId: json['exercise_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
      'index': index,
      'exercise_id': exerciseId,
    };
  }
}

/// Modelo para el progreso del estudiante en ejercicios
class StudentExerciseProgress {
  final int id;
  final int studentId;
  final int exerciseId;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final bool error;

  StudentExerciseProgress({
    required this.id,
    required this.studentId,
    required this.exerciseId,
    this.startedAt,
    this.finishedAt,
    required this.error,
  });

  factory StudentExerciseProgress.fromJson(Map<String, dynamic> json) {
    return StudentExerciseProgress(
      id: json['id'],
      studentId: json['student_id'],
      exerciseId: json['exercise_id'],
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : null,
      finishedAt: json['finished_at'] != null 
          ? DateTime.parse(json['finished_at']) 
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'exercise_id': exerciseId,
      'started_at': startedAt?.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'error': error,
    };
  }
}

/// Modelo para el progreso de lecciones
class LessonProgress {
  final int lessonId;
  final bool isUnlocked;
  final bool isCompleted;
  final double progressPercentage;

  LessonProgress({
    required this.lessonId,
    required this.isUnlocked,
    required this.isCompleted,
    this.progressPercentage = 0.0,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lesson_id'],
      isUnlocked: json['is_unlocked'],
      isCompleted: json['is_completed'],
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
      'progress_percentage': progressPercentage,
    };
  }
}