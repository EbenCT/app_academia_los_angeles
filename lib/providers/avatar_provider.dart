// lib/providers/avatar_provider.dart
import 'package:flutter/foundation.dart';
import '../models/avatar_model.dart';
import '../services/avatar_service.dart';

/// Provider que maneja el estado del avatar en la aplicación
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
  
  /// Actualiza campos específicos del avatar
  Future<bool> updateAvatar(String userId, Map<String, dynamic> fields) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _avatarService.updateAvatarFields(userId, fields);
      
      if (success) {
        // Recargar el avatar actualizado
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