// lib/models/shop_item_model.dart
import 'package:flutter/material.dart';

enum ShopItemType {
  accessory,    // Accesorios para el avatar
  booster,      // Potenciadores temporales
  theme,        // Temas para la app
  badge,        // Insignias especiales
}

enum ShopItemRarity {
  common,       // Común - Verde
  rare,         // Raro - Azul  
  epic,         // Épico - Morado
  legendary,    // Legendario - Dorado
}

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopItemType type;
  final ShopItemRarity rarity;
  final IconData icon;
  final List<Color> colors;
  final bool isOwned;
  final bool isEquipped;
  final Map<String, dynamic>? effects; // Para potenciadores

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.rarity,
    required this.icon,
    required this.colors,
    this.isOwned = false,
    this.isEquipped = false,
    this.effects,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      type: ShopItemType.values.firstWhere(
        (e) => e.toString() == 'ShopItemType.${json['type']}',
        orElse: () => ShopItemType.accessory,
      ),
      rarity: ShopItemRarity.values.firstWhere(
        (e) => e.toString() == 'ShopItemRarity.${json['rarity']}',
        orElse: () => ShopItemRarity.common,
      ),
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      colors: (json['colors'] as List<dynamic>)
          .map((color) => Color(color))
          .toList(),
      isOwned: json['is_owned'] ?? false,
      isEquipped: json['is_equipped'] ?? false,
      effects: json['effects'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'icon_code': icon.codePoint,
      'colors': colors.map((color) => color.value).toList(),
      'is_owned': isOwned,
      'is_equipped': isEquipped,
      'effects': effects,
    };
  }

  ShopItemModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    ShopItemType? type,
    ShopItemRarity? rarity,
    IconData? icon,
    List<Color>? colors,
    bool? isOwned,
    bool? isEquipped,
    Map<String, dynamic>? effects,
  }) {
    return ShopItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      colors: colors ?? this.colors,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
      effects: effects ?? this.effects,
    );
  }

  Color get rarityColor {
    switch (rarity) {
      case ShopItemRarity.common:
        return Colors.green;
      case ShopItemRarity.rare:
        return Colors.blue;
      case ShopItemRarity.epic:
        return Colors.purple;
      case ShopItemRarity.legendary:
        return Colors.amber;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ShopItemType.accessory:
        return 'Accesorio';
      case ShopItemType.booster:
        return 'Potenciador';
      case ShopItemType.theme:
        return 'Tema';
      case ShopItemType.badge:
        return 'Insignia';
    }
  }

  String get rarityDisplayName {
    switch (rarity) {
      case ShopItemRarity.common:
        return 'Común';
      case ShopItemRarity.rare:
        return 'Raro';
      case ShopItemRarity.epic:
        return 'Épico';
      case ShopItemRarity.legendary:
        return 'Legendario';
    }
  }
}