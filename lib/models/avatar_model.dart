// lib/models/avatar_model.dart
class AvatarModel {
  final String gender;
  final int skinToneIndex;
  final int hairStyleIndex;
  final int hairColorIndex;
  final int outfitIndex;
  final int accessoryIndex;

  const AvatarModel({
    required this.gender,
    required this.skinToneIndex,
    required this.hairStyleIndex,
    required this.hairColorIndex,
    required this.outfitIndex,
    required this.accessoryIndex,
  });

  /// Crea un modelo de avatar desde un mapa de datos (ej. respuesta de API o local storage)
  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      gender: json['gender'] ?? 'boy',
      skinToneIndex: json['skinToneIndex'] ?? 0,
      hairStyleIndex: json['hairStyleIndex'] ?? 0,
      hairColorIndex: json['hairColorIndex'] ?? 0,
      outfitIndex: json['outfitIndex'] ?? 0,
      accessoryIndex: json['accessoryIndex'] ?? 0,
    );
  }

  /// Convierte el modelo a un mapa para almacenamiento o API
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'skinToneIndex': skinToneIndex,
      'hairStyleIndex': hairStyleIndex,
      'hairColorIndex': hairColorIndex,
      'outfitIndex': outfitIndex,
      'accessoryIndex': accessoryIndex,
    };
  }

  /// Crea una copia del modelo con campos actualizados
  AvatarModel copyWith({
    String? gender,
    int? skinToneIndex,
    int? hairStyleIndex,
    int? hairColorIndex,
    int? outfitIndex,
    int? accessoryIndex,
  }) {
    return AvatarModel(
      gender: gender ?? this.gender,
      skinToneIndex: skinToneIndex ?? this.skinToneIndex,
      hairStyleIndex: hairStyleIndex ?? this.hairStyleIndex,
      hairColorIndex: hairColorIndex ?? this.hairColorIndex,
      outfitIndex: outfitIndex ?? this.outfitIndex,
      accessoryIndex: accessoryIndex ?? this.accessoryIndex,
    );
  }
  
  /// Crea un avatar por defecto para un nuevo usuario
  factory AvatarModel.defaultAvatar() {
    return const AvatarModel(
      gender: 'boy',
      skinToneIndex: 0,
      hairStyleIndex: 0,
      hairColorIndex: 0,
      outfitIndex: 0,
      accessoryIndex: 0,
    );
  }
}