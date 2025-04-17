import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider para la gestión del tema de la aplicación
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;

  /// Indica si el tema actual es oscuro
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Carga la preferencia de tema guardada
  Future<void> _loadThemePreference() async {
    _isDarkMode = await _storageService.getDarkModePreference();
    notifyListeners();
  }

  /// Cambia entre tema claro y oscuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveDarkModePreference(_isDarkMode);
    notifyListeners();
  }

  /// Establece un tema específico
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      await _storageService.saveDarkModePreference(_isDarkMode);
      notifyListeners();
    }
  }
}