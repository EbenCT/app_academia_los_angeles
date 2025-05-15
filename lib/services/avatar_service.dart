// lib/services/avatar_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_model.dart';

/// Servicio para manejar la personalización y almacenamiento del avatar
class AvatarService {
  static const String _avatarKey = 'user_avatar';
  
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
        return null; // No hay avatar guardado
      }
      
      // Decodificar JSON a Map y luego a AvatarModel
      final Map<String, dynamic> avatarMap = jsonDecode(avatarString);
      return AvatarModel.fromJson(avatarMap);
    } catch (e) {
      print('Error al obtener avatar: $e');
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
  
  /// Actualiza solo ciertos campos del avatar
  Future<bool> updateAvatarFields(String userId, Map<String, dynamic> fields) async {
    try {
      // Obtener el avatar actual
      final currentAvatar = await getOrCreateAvatar(userId);
      
      // Crear un nuevo avatar con los campos actualizados
      final updatedAvatar = currentAvatar.copyWith(
        gender: fields['gender'],
        skinToneIndex: fields['skinToneIndex'],
        hairStyleIndex: fields['hairStyleIndex'],
        hairColorIndex: fields['hairColorIndex'],
        outfitIndex: fields['outfitIndex'],
        accessoryIndex: fields['accessoryIndex'],
      );
      
      // Guardar el avatar actualizado
      return await saveAvatar(userId, updatedAvatar);
    } catch (e) {
      print('Error al actualizar campos del avatar: $e');
      return false;
    }
  }
}