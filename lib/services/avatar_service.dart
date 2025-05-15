// lib/services/avatar_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_model.dart';

/// Servicio mejorado para manejar la personalización y almacenamiento del avatar
class AvatarService {
  static const String _avatarKey = 'user_avatar_v2'; // Versión 2 para el nuevo formato
  
  /// Guarda los datos del avatar en el almacenamiento local
  Future<bool> saveAvatar(String userId, AvatarModel avatar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String avatarKey = '${_avatarKey}_$userId';
      
      // Convertir a JSON y luego a string
      final Map<String, dynamic> avatarMap = avatar.toJson();
      final String avatarString = jsonEncode(avatarMap);
      
      // Guardar en SharedPreferences
      return await prefs.setString(avatarKey, avatarString);
    } catch (e) {
      print('Error al guardar avatar: $e');
      return false;
    }
  }
  
  /// Obtiene los datos del avatar desde el almacenamiento local
  Future<AvatarModel?> getAvatar(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String avatarKey = '${_avatarKey}_$userId';
      
      // Obtener la cadena JSON
      final String? avatarString = prefs.getString(avatarKey);
      
      if (avatarString == null) {
        // Buscar en el formato anterior si existe
        return await _migrateFromOldFormat(userId, prefs);
      }
      
      // Decodificar JSON a Map y luego a AvatarModel
      final Map<String, dynamic> avatarMap = jsonDecode(avatarString);
      return AvatarModel.fromJson(avatarMap);
    } catch (e) {
      print('Error al obtener avatar: $e');
      return null;
    }
  }
  
  /// Migra de la versión anterior del avatar a la nueva si existe
  Future<AvatarModel?> _migrateFromOldFormat(String userId, SharedPreferences prefs) async {
    try {
      final String oldAvatarKey = 'user_avatar_$userId';
      final String? oldAvatarString = prefs.getString(oldAvatarKey);
      
      if (oldAvatarString == null) {
        return null; // No hay avatar en ningún formato
      }
      
      // Convertir del formato antiguo al nuevo
      final Map<String, dynamic> oldAvatarMap = jsonDecode(oldAvatarString);
      
      // Crear un nuevo avatar con valores basados en el antiguo
      final newAvatar = AvatarModel(
        gender: oldAvatarMap['gender'] ?? 'boy',
        skinToneIndex: oldAvatarMap['skinToneIndex'] ?? 0,
        eyesIndex: 0, // Valores por defecto para nuevos campos
        noseIndex: 0,
        mouthIndex: 0,
        hair: HairModel(
          styleIndex: oldAvatarMap['hairStyleIndex'] ?? 0,
          colorIndex: oldAvatarMap['hairColorIndex'] ?? 0,
        ),
        outfit: OutfitModel(
          topIndex: oldAvatarMap['outfitIndex'] ?? 0,
          bottomIndex: 0,
          shoesIndex: 0,
        ),
        accessories: AccessoriesModel(
          hasGlasses: (oldAvatarMap['accessoryIndex'] ?? 0) == 1,
          hasHat: (oldAvatarMap['accessoryIndex'] ?? 0) == 2,
          hasBackpack: (oldAvatarMap['accessoryIndex'] ?? 0) == 3,
        ),
      );
      
      // Guardar en el nuevo formato y retornar
      await saveAvatar(userId, newAvatar);
      return newAvatar;
    } catch (e) {
      print('Error al migrar avatar antiguo: $e');
      return null;
    }
  }
  
  /// Obtiene un avatar por defecto o el almacenado si existe
  Future<AvatarModel> getOrCreateAvatar(String userId) async {
    final existingAvatar = await getAvatar(userId);
    if (existingAvatar != null) {
      return existingAvatar;
    }
    
    // Crear y guardar un avatar por defecto
    final defaultAvatar = AvatarModel.defaultAvatar();
    await saveAvatar(userId, defaultAvatar);
    return defaultAvatar;
  }
  
  /// Actualiza el género del avatar
  Future<bool> updateGender(String userId, String gender) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedAvatar = currentAvatar.copyWith(gender: gender);
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar género: $e');
      return false;
    }
  }
  
  /// Actualiza el tono de piel
  Future<bool> updateSkinTone(String userId, int skinToneIndex) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedAvatar = currentAvatar.copyWith(skinToneIndex: skinToneIndex);
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar tono de piel: $e');
      return false;
    }
  }
  
  /// Actualiza características faciales
  Future<bool> updateFacialFeatures(String userId, {int? eyesIndex, int? noseIndex, int? mouthIndex}) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedAvatar = currentAvatar.copyWith(
        eyesIndex: eyesIndex,
        noseIndex: noseIndex,
        mouthIndex: mouthIndex,
      );
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar características faciales: $e');
      return false;
    }
  }
  
  /// Actualiza el cabello
  Future<bool> updateHair(String userId, {int? styleIndex, int? colorIndex}) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedHair = currentAvatar.hair.copyWith(
        styleIndex: styleIndex,
        colorIndex: colorIndex,
      );
      final updatedAvatar = currentAvatar.copyWith(hair: updatedHair);
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar cabello: $e');
      return false;
    }
  }
  
  /// Actualiza la ropa
  Future<bool> updateOutfit(String userId, {int? topIndex, int? bottomIndex, int? shoesIndex}) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedOutfit = currentAvatar.outfit.copyWith(
        topIndex: topIndex,
        bottomIndex: bottomIndex,
        shoesIndex: shoesIndex,
      );
      final updatedAvatar = currentAvatar.copyWith(outfit: updatedOutfit);
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar ropa: $e');
      return false;
    }
  }
  
  /// Actualiza los accesorios
  Future<bool> updateAccessories(String userId, {bool? hasGlasses, bool? hasHat, bool? hasBackpack}) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      final updatedAccessories = currentAvatar.accessories.copyWith(
        hasGlasses: hasGlasses,
        hasHat: hasHat,
        hasBackpack: hasBackpack,
      );
      final updatedAvatar = currentAvatar.copyWith(accessories: updatedAccessories);
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar accesorios: $e');
      return false;
    }
  }
  
  /// Actualiza varios campos del avatar a la vez
  Future<bool> updateMultipleFields(String userId, Map<String, dynamic> updates) async {
    try {
      final currentAvatar = await getOrCreateAvatar(userId);
      
      // Extraer valores básicos
      final gender = updates['gender'];
      final skinToneIndex = updates['skinToneIndex'];
      final eyesIndex = updates['eyesIndex'];
      final noseIndex = updates['noseIndex'];
      final mouthIndex = updates['mouthIndex'];
      
      // Extraer valores de cabello
      HairModel? updatedHair;
      if (updates.containsKey('hair')) {
        final hairUpdates = updates['hair'];
        updatedHair = currentAvatar.hair.copyWith(
          styleIndex: hairUpdates['styleIndex'],
          colorIndex: hairUpdates['colorIndex'],
        );
      }
      
      // Extraer valores de ropa
      OutfitModel? updatedOutfit;
      if (updates.containsKey('outfit')) {
        final outfitUpdates = updates['outfit'];
        updatedOutfit = currentAvatar.outfit.copyWith(
          topIndex: outfitUpdates['topIndex'],
          bottomIndex: outfitUpdates['bottomIndex'],
          shoesIndex: outfitUpdates['shoesIndex'],
        );
      }
      
      // Extraer valores de accesorios
      AccessoriesModel? updatedAccessories;
      if (updates.containsKey('accessories')) {
        final accessoriesUpdates = updates['accessories'];
        updatedAccessories = currentAvatar.accessories.copyWith(
          hasGlasses: accessoriesUpdates['hasGlasses'],
          hasHat: accessoriesUpdates['hasHat'],
          hasBackpack: accessoriesUpdates['hasBackpack'],
        );
      }
      
      // Crear avatar actualizado
      final updatedAvatar = currentAvatar.copyWith(
        gender: gender,
        skinToneIndex: skinToneIndex,
        eyesIndex: eyesIndex,
        noseIndex: noseIndex,
        mouthIndex: mouthIndex,
        hair: updatedHair,
        outfit: updatedOutfit,
        accessories: updatedAccessories,
      );
      
      // Guardar avatar actualizado
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar múltiples campos: $e');
      return false;
    }
  }
}