import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Servicio para almacenamiento local de datos
class StorageService {
  /// Guarda el token de autenticación
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.authTokenKey, token);
  }

  /// Obtiene el token de autenticación guardado
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.authTokenKey);
  }

  /// Elimina el token de autenticación
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.authTokenKey);
  }

  /// Guarda la preferencia de tema oscuro
  Future<void> saveDarkModePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.themeKey, isDarkMode);
  }

  /// Obtiene la preferencia de tema oscuro guardada
  Future<bool> getDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.themeKey) ?? false;
  }
}