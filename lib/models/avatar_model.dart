// lib/models/avatar_model.dart
class AvatarModel {
  final String gender;
  final int skinToneIndex;
  final int eyesIndex;
  final int noseIndex;
  final int mouthIndex;
  final HairModel hair;
  final OutfitModel outfit;
  final AccessoriesModel accessories;

  const AvatarModel({
    required this.gender,
    required this.skinToneIndex,
    required this.eyesIndex,
    required this.noseIndex, 
    required this.mouthIndex,
    required this.hair,
    required this.outfit,
    required this.accessories,
  });

  /// Crea un modelo de avatar desde un mapa de datos (ej. respuesta de API o local storage)
  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      gender: json['gender'] ?? 'boy',
      skinToneIndex: json['skinToneIndex'] ?? 0,
      eyesIndex: json['eyesIndex'] ?? 0,
      noseIndex: json['noseIndex'] ?? 0,
      mouthIndex: json['mouthIndex'] ?? 0,
      hair: HairModel.fromJson(json['hair'] ?? {}),
      outfit: OutfitModel.fromJson(json['outfit'] ?? {}),
      accessories: AccessoriesModel.fromJson(json['accessories'] ?? {}),
    );
  }

  /// Convierte el modelo a un mapa para almacenamiento o API
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'skinToneIndex': skinToneIndex,
      'eyesIndex': eyesIndex,
      'noseIndex': noseIndex,
      'mouthIndex': mouthIndex,
      'hair': hair.toJson(),
      'outfit': outfit.toJson(),
      'accessories': accessories.toJson(),
    };
  }

  /// Crea una copia del modelo con campos actualizados
  AvatarModel copyWith({
    String? gender,
    int? skinToneIndex,
    int? eyesIndex,
    int? noseIndex,
    int? mouthIndex,
    HairModel? hair,
    OutfitModel? outfit,
    AccessoriesModel? accessories,
  }) {
    return AvatarModel(
      gender: gender ?? this.gender,
      skinToneIndex: skinToneIndex ?? this.skinToneIndex,
      eyesIndex: eyesIndex ?? this.eyesIndex,
      noseIndex: noseIndex ?? this.noseIndex,
      mouthIndex: mouthIndex ?? this.mouthIndex,
      hair: hair ?? this.hair,
      outfit: outfit ?? this.outfit,
      accessories: accessories ?? this.accessories,
    );
  }
  
  /// Crea un avatar por defecto para un nuevo usuario
  factory AvatarModel.defaultAvatar() {
    return AvatarModel(
      gender: 'boy',
      skinToneIndex: 0,
      eyesIndex: 0,
      noseIndex: 0,
      mouthIndex: 0,
      hair: HairModel.defaultHair(),
      outfit: OutfitModel.defaultOutfit(),
      accessories: AccessoriesModel.defaultAccessories(),
    );
  }
}

/// Modelo para el cabello del avatar
class HairModel {
  final int styleIndex;
  final int colorIndex;

  const HairModel({
    required this.styleIndex,
    required this.colorIndex,
  });

  factory HairModel.fromJson(Map<String, dynamic> json) {
    return HairModel(
      styleIndex: json['styleIndex'] ?? 0,
      colorIndex: json['colorIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleIndex': styleIndex,
      'colorIndex': colorIndex,
    };
  }

  HairModel copyWith({
    int? styleIndex,
    int? colorIndex,
  }) {
    return HairModel(
      styleIndex: styleIndex ?? this.styleIndex,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  factory HairModel.defaultHair() {
    return const HairModel(
      styleIndex: 0,
      colorIndex: 0,
    );
  }
}

/// Modelo para la ropa del avatar
class OutfitModel {
  final int topIndex;
  final int bottomIndex;
  final int shoesIndex;

  const OutfitModel({
    required this.topIndex,
    required this.bottomIndex,
    required this.shoesIndex,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      topIndex: json['topIndex'] ?? 0,
      bottomIndex: json['bottomIndex'] ?? 0,
      shoesIndex: json['shoesIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topIndex': topIndex,
      'bottomIndex': bottomIndex,
      'shoesIndex': shoesIndex,
    };
  }

  OutfitModel copyWith({
    int? topIndex,
    int? bottomIndex,
    int? shoesIndex,
  }) {
    return OutfitModel(
      topIndex: topIndex ?? this.topIndex,
      bottomIndex: bottomIndex ?? this.bottomIndex,
      shoesIndex: shoesIndex ?? this.shoesIndex,
    );
  }

  factory OutfitModel.defaultOutfit() {
    return const OutfitModel(
      topIndex: 0,
      bottomIndex: 0,
      shoesIndex: 0,
    );
  }
}

/// Modelo para los accesorios del avatar
class AccessoriesModel {
  final bool hasGlasses;
  final bool hasHat;
  final bool hasBackpack;

  const AccessoriesModel({
    required this.hasGlasses,
    required this.hasHat,
    required this.hasBackpack,
  });

  factory AccessoriesModel.fromJson(Map<String, dynamic> json) {
    return AccessoriesModel(
      hasGlasses: json['hasGlasses'] ?? false,
      hasHat: json['hasHat'] ?? false,
      hasBackpack: json['hasBackpack'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasGlasses': hasGlasses,
      'hasHat': hasHat,
      'hasBackpack': hasBackpack,
    };
  }

  AccessoriesModel copyWith({
    bool? hasGlasses,
    bool? hasHat,
    bool? hasBackpack,
  }) {
    return AccessoriesModel(
      hasGlasses: hasGlasses ?? this.hasGlasses,
      hasHat: hasHat ?? this.hasHat,
      hasBackpack: hasBackpack ?? this.hasBackpack,
    );
  }

  factory AccessoriesModel.defaultAccessories() {
    return const AccessoriesModel(
      hasGlasses: false,
      hasHat: false,
      hasBackpack: false,
    );
  }
}