// lib/providers/avatar_provider.dart
import 'package:flutter/foundation.dart';
import '../models/avatar_model.dart';
import '../services/avatar_service.dart';

/// Provider mejorado que maneja el estado del avatar en la aplicación
class AvatarProvider extends ChangeNotifier {
  final AvatarService _avatarService = AvatarService();
  
  bool _isLoading = false;
  String? _error;
  AvatarModel? _avatar;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AvatarModel? get avatar => _avatar;
  
  /// Carga el avatar para un usuario específico
  Future<void> loadAvatar(String userId) async {
    _setLoading(true);
    _error = null;
    
    try {
      _avatar = await _avatarService.getOrCreateAvatar(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  /// Guarda los cambios en el avatar
  Future<bool> saveAvatar(String userId, AvatarModel newAvatar) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.saveAvatar(userId, newAvatar);
      
      if (success) {
        _avatar = newAvatar;
      } else {
        _error = 'No se pudo guardar el avatar';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza el género del avatar
  Future<bool> updateGender(String userId, String gender) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateGender(userId, gender);
      
      if (success) {
        await loadAvatar(userId); // Recargar el avatar actualizado
      } else {
        _error = 'No se pudo actualizar el género';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza el tono de piel
  Future<bool> updateSkinTone(String userId, int skinToneIndex) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateSkinTone(userId, skinToneIndex);
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar el tono de piel';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza características faciales
  Future<bool> updateFacialFeatures(String userId, {int? eyesIndex, int? noseIndex, int? mouthIndex}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateFacialFeatures(
        userId, 
        eyesIndex: eyesIndex, 
        noseIndex: noseIndex, 
        mouthIndex: mouthIndex
      );
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar las características faciales';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza el cabello
  Future<bool> updateHair(String userId, {int? styleIndex, int? colorIndex}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateHair(
        userId, 
        styleIndex: styleIndex, 
        colorIndex: colorIndex
      );
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar el cabello';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza la ropa
  Future<bool> updateOutfit(String userId, {int? topIndex, int? bottomIndex, int? shoesIndex}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateOutfit(
        userId, 
        topIndex: topIndex, 
        bottomIndex: bottomIndex, 
        shoesIndex: shoesIndex
      );
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar la ropa';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza los accesorios
  Future<bool> updateAccessories(String userId, {bool? hasGlasses, bool? hasHat, bool? hasBackpack}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateAccessories(
        userId, 
        hasGlasses: hasGlasses, 
        hasHat: hasHat, 
        hasBackpack: hasBackpack
      );
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar los accesorios';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza múltiples campos a la vez
  Future<bool> updateMultipleFields(String userId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateMultipleFields(userId, updates);
      
      if (success) {
        await loadAvatar(userId);
      } else {
        _error = 'No se pudo actualizar el avatar';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Cambia el estado de carga y notifica a los listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Limpia errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}