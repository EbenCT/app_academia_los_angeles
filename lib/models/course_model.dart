// lib/models/course_model.dart
class CourseModel {
  final int id;
  final String title;
  final String? description;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}