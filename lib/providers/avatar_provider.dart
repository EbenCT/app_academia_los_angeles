// lib/providers/avatar_provider.dart
import 'package:flutter/foundation.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que maneja el estado del avatar en la aplicación usando Fluttermoji
class AvatarProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Inicializa el avatar para un usuario específico
  Future<void> loadAvatar(String userId) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Inicializar la configuración de Fluttermoji para este usuario
      await _initializeFluttermojiForUser(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  /// Inicializa Fluttermoji para un usuario específico
  Future<void> _initializeFluttermojiForUser(String userId) async {
    try {
      // Configuramos la clave para almacenar los datos de este usuario
      await _setUserKey(userId);
      
      // En la versión 1.0.2 no existe synchWithSharedPreferences
      // Simplemente podemos cargar la configuración existente
      // La inicialización ya se hizo en main.dart
    } catch (e) {
      print('Error al inicializar Fluttermoji: $e');
      rethrow;
    }
  }
  
  /// Establece la clave de usuario para el almacenamiento de Fluttermoji
  Future<void> _setUserKey(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardamos el userId actual para poder gestionar distintos avatares
      await prefs.setString('current_fluttermoji_user', userId);
      
      // Si no existe una configuración para este usuario, creamos una por defecto
      final String fluttermojiKey = 'fluttermoji_$userId';
      if (!prefs.containsKey(fluttermojiKey)) {
        // Fluttermoji guardará automáticamente su configuración por defecto
        // cuando llamemos a synchWithSharedPreferences()
      }
    } catch (e) {
      print('Error al establecer la clave de usuario para Fluttermoji: $e');
      rethrow;
    }
  }
  
  /// Guarda la configuración del avatar
  Future<bool> saveAvatar() async {
    _setLoading(true);
    _error = null;
    
    try {
      // En la versión 1.0.2, Fluttermoji guarda automáticamente
      // No es necesario llamar a synchWithSharedPreferences

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Obtiene la configuración actual del avatar
  Future<Map<String, dynamic>> getAvatarData() async {
    try {
      final fluttermojiController = FluttermojiController();
      // En la versión 1.0.2, este método devuelve Map<String?, int> 
      // Necesitamos convertirlo a Map<String, dynamic>
      final options = await fluttermojiController.getFluttermojiOptions();
      
      // Convertir Map<String?, int> a Map<String, dynamic>
      final Map<String, dynamic> result = {};
      options.forEach((key, value) {
        if (key != null) {
          result[key] = value;
        }
      });
      
      return result;
    } catch (e) {
      _error = e.toString();
      return {};
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