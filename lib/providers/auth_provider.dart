// lib/providers/auth_provider.dart (con limpieza de datos)
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

/// Provider que maneja el estado de autenticación en la aplicación
class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  UserModel? _currentUser;
  int _loginAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockUntil;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  bool get isLocked => _isLocked;
  int get remainingAttempts => AppConfig.maxLoginAttempts - _loginAttempts;

  // Constructor que recibe el cliente GraphQL
  AuthProvider(GraphQLClient client) {
    _authService = AuthService(client);
    // Intenta restaurar la sesión al iniciar la app
    _checkSavedSession();
  }

  /// Verifica si hay una sesión guardada
  Future<void> _checkSavedSession() async {
    _setLoading(true);
    try {
      final token = await _storageService.getAuthToken();
      if (token != null) {
        final userData = await _authService.getUserData(token);
        _currentUser = UserModel.fromJson(userData);
        _isAuthenticated = true;
      }
    } catch (e) {
      // Token inválido o expirado
      await _storageService.clearAuthToken();
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Intenta iniciar sesión con las credenciales proporcionadas
  Future<bool> login(String email, String password) async {
    // Verificar si la cuenta está bloqueada
    if (_isLocked) {
      if (_lockUntil != null && DateTime.now().isAfter(_lockUntil!)) {
        // Desbloquear si ya pasó el tiempo de bloqueo
        _isLocked = false;
        _loginAttempts = 0;
      } else {
        _error = 'Cuenta bloqueada por múltiples intentos fallidos. Intenta más tarde.';
        notifyListeners();
        return false;
      }
    }
    
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        // Login exitoso
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _loginAttempts = 0;
        
        _setLoading(false);
        return true;
      } else {
        // Login fallido
        _loginAttempts++;
        _error = result['message'] ?? 'Credenciales inválidas';
        
        // Verificar si se debe bloquear la cuenta
        if (_loginAttempts >= AppConfig.maxLoginAttempts) {
          _isLocked = true;
          _lockUntil = DateTime.now().add(Duration(seconds: AppConfig.lockoutTime));
          _error = 'Demasiados intentos fallidos. Cuenta bloqueada por ${AppConfig.lockoutTime ~/ 60} minutos.';
        }
        
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  /// Cierra la sesión del usuario y limpia todos los datos locales
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Cerrar sesión en el servidor
      await _authService.logout();
      
      // Limpiar token de autenticación
      await _storageService.clearAuthToken();
      
      // Limpiar todos los datos locales relacionados con el usuario
      await _clearAllLocalData();
      
    } catch (e) {
      // Intentar cerrar sesión de todos modos
      print('Error durante logout: $e');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _setLoading(false);
    }
  }

/// Limpia todos los datos locales almacenados
  Future<void> _clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiar datos del estudiante
      await prefs.remove('student_level');
      await prefs.remove('student_xp');
      await prefs.remove('student_has_classroom');
      await prefs.remove('student_course_name');
      await prefs.remove('student_classroom_name');
      await prefs.remove('student_subjects');
      
      // Limpiar datos de monedas
      await prefs.remove('coin_amount');
      await prefs.remove('coin_last_updated');
      await prefs.remove('owned_items');
      await prefs.remove('equipped_items');
      
      // Limpiar datos de potenciadores
      await prefs.remove('active_booster');
      
      // Limpiar desafíos diarios y progreso de lecciones
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith('daily_challenge_') || 
            key.startsWith('completed_lessons_') || 
            key.startsWith('unlocked_lessons_') ||
            key.startsWith('subject_')) {
          await prefs.remove(key);
        }
      }
      
      // Limpiar datos de avatar
      final currentUser = await prefs.getString('current_fluttermoji_user');
      if (currentUser != null) {
        await prefs.remove('fluttermoji_$currentUser');
        await prefs.remove('current_fluttermoji_user');
      }
      
      // Limpiar preferencias de tema (opcional - puedes mantener esto)
      // await prefs.remove('dark_mode');
      
      print('Todos los datos locales han sido limpiados');
    } catch (e) {
      print('Error limpiando datos locales: $e');
    }
  }
  /// Cambia el estado de carga y notifica a los listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Limpia los errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> registerStudent(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _authService.registerStudent(
        email,
        password,
        firstName,
        lastName,
      );
      if (result['success']) {
        // Registro exitoso
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        // Registro fallido
        _error = result['message'] ?? 'Error en el registro';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerTeacher(
    String email,
    String password,
    String firstName,
    String lastName,
    int cellphone,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _authService.registerTeacher(
        email,
        password,
        firstName,
        lastName,
        cellphone,
      );
      if (result['success']) {
        // Registro exitoso
        _currentUser = UserModel.fromJson(result['user']);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        // Registro fallido
        _error = result['message'] ?? 'Error en el registro';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String role,
  ) async {
    // Por compatibilidad, mantenemos este método pero ahora delegamos a registerStudent
    return registerStudent(email, password, firstName, lastName);
  }

  // Método auxiliar para determinar la ruta principal según el rol
  String getMainRouteForUser() {
    if (_currentUser?.role == 'teacher') {
      return '/main-teacher';
    } else {
      return '/main';
    }
  }
}