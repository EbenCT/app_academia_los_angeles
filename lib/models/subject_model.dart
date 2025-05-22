// lib/models/subject_model.dart
class SubjectModel {
  final int id;
  final String code;
  final String name;
  final String? description;

  const SubjectModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
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