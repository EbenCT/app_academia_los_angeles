// lib/models/active_booster_model.dart
class ActiveBoosterModel {
  final String id;
  final String name;
  final double xpMultiplier;
  final double coinMultiplier;
  final DateTime startTime;
  final Duration duration;
  final String iconPath;

  const ActiveBoosterModel({
    required this.id,
    required this.name,
    required this.xpMultiplier,
    required this.coinMultiplier,
    required this.startTime,
    required this.duration,
    required this.iconPath,
  });

  // Tiempo restante del potenciador
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Si el potenciador está activo
  bool get isActive => remainingTime > Duration.zero;

  // Porcentaje de tiempo restante (0.0 a 1.0)
  double get progressPercentage {
    if (!isActive) return 0.0;
    final elapsed = DateTime.now().difference(startTime);
    return 1.0 - (elapsed.inMilliseconds / duration.inMilliseconds);
  }

  factory ActiveBoosterModel.fromJson(Map<String, dynamic> json) {
    return ActiveBoosterModel(
      id: json['id'],
      name: json['name'],
      xpMultiplier: json['xp_multiplier']?.toDouble() ?? 1.0,
      coinMultiplier: json['coin_multiplier']?.toDouble() ?? 1.0,
      startTime: DateTime.parse(json['start_time']),
      duration: Duration(seconds: json['duration_seconds']),
      iconPath: json['icon_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'xp_multiplier': xpMultiplier,
      'coin_multiplier': coinMultiplier,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'icon_path': iconPath,
    };
  }
}