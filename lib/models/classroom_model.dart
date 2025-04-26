// lib/models/classroom_model.dart
class ClassroomModel {
  final int id;
  final String code;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int teacherId;
  final int courseId;
  final String courseName;
  final int studentsCount;

  const ClassroomModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.createdAt,
    required this.teacherId,
    required this.courseId,
    required this.courseName,
    this.studentsCount = 0,
  });

factory ClassroomModel.fromJson(Map<String, dynamic> json) {
  try {
    return ClassroomModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      teacherId: json['teacher']?['id'] ?? 0, // Manejamos el caso donde teacher podría ser null
      courseId: json['course']?['id'] ?? 0,
      courseName: json['course']?['title'] ?? 'Sin curso',
      studentsCount: (json['students'] as List<dynamic>?)?.length ?? 0,
    );
  } catch (e) {
    print('Error parsing ClassroomModel: $e');
    print('JSON data: $json');
    rethrow; // Relanzamos la excepción para manejarla en un nivel superior
  }
}
}