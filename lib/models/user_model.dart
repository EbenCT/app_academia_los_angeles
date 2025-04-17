/// Modelo que representa un usuario en la aplicación.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int points;
  final List<String> achievements;
  final int level;
  final String role; // estudiante, profesor, admin

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.points = 0,
    this.achievements = const [],
    this.level = 1,
    this.role = 'estudiante',
  });

  /// Crea un usuario desde un mapa de datos (ej. respuesta de API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      points: json['points'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      level: json['level'] ?? 1,
      role: json['role'] ?? 'estudiante',
    );
  }

  /// Convierte el usuario a un mapa para almacenamiento o API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'points': points,
      'achievements': achievements,
      'level': level,
      'role': role,
    };
  }

  /// Crea una copia del usuario con campos actualizados
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? points,
    List<String>? achievements,
    int? level,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      achievements: achievements ?? this.achievements,
      level: level ?? this.level,
      role: role ?? this.role,
    );
  }
}