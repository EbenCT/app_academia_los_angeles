// lib/models/achievement_model.dart
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool unlocked;
  final int pointsValue;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlocked,
    this.pointsValue = 50,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'emoji_events',
      unlocked: json['unlocked'] ?? false,
      pointsValue: json['points_value'] ?? 50,
      unlockedAt: json['unlocked_at'] != null 
        ? DateTime.parse(json['unlocked_at']) 
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': iconName,
      'unlocked': unlocked,
      'pointsValue': pointsValue,
    };
  }
}