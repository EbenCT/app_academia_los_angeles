/// Configuración global de la aplicación
class AppConfig {
  /// Nombre de la aplicación
  static const String appName = 'Colegio Los Ángeles';
  
  /// Versión de la aplicación
  static const String appVersion = '1.0.0';
  
  /// Clave para almacenar el token de autenticación
  static const String authTokenKey = 'auth_token';
  
  /// Clave para almacenar el tema
  static const String themeKey = 'dark_mode';
  
  /// Tiempo de expiración de la sesión en segundos (3 días)
  static const int sessionTimeout = 259200;
  
  /// Configuración del timeout para peticiones http (en segundos)
  static const int apiTimeout = 30;
  
  /// Número máximo de intentos de login fallidos
  static const int maxLoginAttempts = 5;
  
  /// Tiempo de bloqueo después de máximos intentos fallidos (en segundos)
  static const int lockoutTime = 300; // 5 minutos
}