// lib/models/lesson_models.dart
class Topic {
  final int id;
  final String name;
  final String? description;
  final int xpReward;
  final List<Lesson> lessons;

  Topic({
    required this.id,
    required this.name,
    this.description,
    required this.xpReward,
    required this.lessons,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      xpReward: json['xpReward'],
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String? content;
  final String? imgLink;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    this.content,
    this.imgLink,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imgLink: json['img_link'],
      exercises: (json['exercises'] as List)
          .map((exercise) => Exercise.fromJson(exercise))
          .toList(),
    );
  }
}

class Exercise {
  final int id;
  final String severity;
  final String question;
  final int type; // 1 = selección múltiple, 2 = ordenar
  final int coins;
  final List<ExerciseOption> options;

  Exercise({
    required this.id,
    required this.severity,
    required this.question,
    required this.type,
    required this.coins,
    required this.options,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      severity: json['severity'],
      question: json['question'],
      type: json['type'],
      coins: json['coins'],
      options: (json['options'] as List)
          .map((option) => ExerciseOption.fromJson(option))
          .toList(),
    );
  }
}

class ExerciseOption {
  final int id;
  final String text;
  final bool isCorrect;
  final int index;

  ExerciseOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.index,
  });

  factory ExerciseOption.fromJson(Map<String, dynamic> json) {
    return ExerciseOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
      index: json['index'],
    );
  }
}