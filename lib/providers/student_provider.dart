// lib/providers/student_provider.dart (con persistencia)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/student_service.dart';
import '../models/subject_model.dart';
import '../providers/coin_provider.dart';
import 'booster_provider.dart';

class StudentProvider extends ChangeNotifier {
  late final StudentService _studentService;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _studentData;
  bool _hasClassroom = false;
  int _level = 1;
  int _xp = 0;
  List<SubjectModel> _subjects = [];
  String? _courseName;
  String? _classroomName;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get studentData => _studentData;
  bool get hasClassroom => _hasClassroom;
  int get level => _level;
  int get xp => _xp;
  List<SubjectModel> get subjects => _subjects;
  String? get courseName => _courseName;
  String? get classroomName => _classroomName;

  // Constructor
  StudentProvider(GraphQLClient client) {
    _studentService = StudentService(client);
    _loadStudentData();
  }

  // Cargar datos locales y luego del servidor
  Future<void> _loadStudentData() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Primero cargar datos locales para una experiencia más rápida
      await _loadLocalData();
      
      // Luego intentar sincronizar con el servidor
      final data = await _studentService.getStudentInfo();
      _studentData = data;
      _hasClassroom = data['classroom'] != null;
      
      // Solo actualizar nivel y XP del servidor si es mayor que el local
      final serverLevel = data['level'] ?? 1;
      final serverXp = data['xp'] ?? 0;
      
      if (serverLevel > _level || (serverLevel == _level && serverXp > _xp)) {
        _level = serverLevel;
        _xp = serverXp;
        await _saveLocalData(); // Guardar los datos actualizados
      } else if (_level > serverLevel || (_level == serverLevel && _xp > serverXp)) {
        // Si el local es mayor, sincronizar al servidor (en una implementación real)
        print('Datos locales más recientes que el servidor - sincronización pendiente');
      }
      
      // Extraer información del aula y materias si existe
      if (_hasClassroom && data['classroom'] != null) {
        final classroom = data['classroom'];
        _classroomName = classroom['name'];
        
        if (classroom['course'] != null) {
          final course = classroom['course'];
          _courseName = course['title'];
          
          // Extraer las materias del curso
          if (course['subjects'] != null) {
            final subjectsData = course['subjects'] as List<dynamic>;
            _subjects = subjectsData
                .map((subjectJson) => SubjectModel.fromJson(subjectJson))
                .toList();
          }
        }
      }
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Cargar datos desde SharedPreferences
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _level = prefs.getInt('student_level') ?? 1;
      _xp = prefs.getInt('student_xp') ?? 0;
      _hasClassroom = prefs.getBool('student_has_classroom') ?? false;
      _courseName = prefs.getString('student_course_name');
      _classroomName = prefs.getString('student_classroom_name');
      
      // Cargar materias si existen
      final subjectsJson = prefs.getStringList('student_subjects') ?? [];
      _subjects = subjectsJson.map((subjectString) {
        // Formato simple: id|code|name|description
        final parts = subjectString.split('|');
        if (parts.length >= 3) {
          return SubjectModel(
            id: int.tryParse(parts[0]) ?? 0,
            code: parts[1],
            name: parts[2],
            description: parts.length > 3 ? parts[3] : null,
          );
        }
        return null;
      }).where((subject) => subject != null).cast<SubjectModel>().toList();
      
      print('Datos locales cargados - Nivel: $_level, XP: $_xp');
    } catch (e) {
      print('Error cargando datos locales: $e');
    }
  }

  // Guardar datos en SharedPreferences
  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('student_level', _level);
      await prefs.setInt('student_xp', _xp);
      await prefs.setBool('student_has_classroom', _hasClassroom);
      
      if (_courseName != null) {
        await prefs.setString('student_course_name', _courseName!);
      }
      
      if (_classroomName != null) {
        await prefs.setString('student_classroom_name', _classroomName!);
      }
      
      // Guardar materias en formato simple
      final subjectsStrings = _subjects.map((subject) {
        return '${subject.id}|${subject.code}|${subject.name}|${subject.description ?? ''}';
      }).toList();
      await prefs.setStringList('student_subjects', subjectsStrings);
      
      print('Datos locales guardados - Nivel: $_level, XP: $_xp');
    } catch (e) {
      print('Error guardando datos locales: $e');
    }
  }

  // Unirse a un aula por ID
  Future<bool> joinClassroom(int classroomId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _studentService.joinClassroom(classroomId);
      _studentData = data;
      _hasClassroom = data['classroom'] != null;
      
      if (_hasClassroom && data['classroom'] != null) {
        final classroom = data['classroom'];
        _classroomName = classroom['name'];
        
        if (classroom['course'] != null) {
          final course = classroom['course'];
          _courseName = course['title'];
          
          // Extraer las materias del curso
          if (course['subjects'] != null) {
            final subjectsData = course['subjects'] as List<dynamic>;
            _subjects = subjectsData
                .map((subjectJson) => SubjectModel.fromJson(subjectJson))
                .toList();
          }
        }
      }
      
      // Guardar datos localmente
      await _saveLocalData();
      
      _setLoading(false);
      return _hasClassroom;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Validar y unirse a un aula por código
  Future<bool> joinClassroomByCode(String code) async {
    _setLoading(true);
    _error = null;
    try {
      print('Intentando unirse con código: $code');
      // Convertir el código a ID
      final classroomId = int.tryParse(code);
      if (classroomId != null && classroomId > 0) {
        return await joinClassroom(classroomId);
      } else {
        _error = 'Código de aula inválido. Debe ser un número';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Error al unirse por código: $e');
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

// Completar un desafío con recompensas mejoradas
  Future<void> completeChallenge(int pointsEarned, {BuildContext? context}) async {
    final oldLevel = _level;
    
    // Aplicar multiplicador de XP si hay potenciador activo
    double finalXp = pointsEarned.toDouble();
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        finalXp *= boosterProvider.xpMultiplier;
      }
    }
    
    _xp += finalXp.round();
    
    // Lógica simple para subir de nivel
    if (_xp >= _level * 100) {
      _level++;
    }
    
    // Calcular monedas ganadas (basado en puntos)
    double finalCoins = (pointsEarned * 0.5); // 50% de los puntos como monedas
    
    // Aplicar multiplicador de monedas si hay potenciador activo
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        finalCoins *= boosterProvider.coinMultiplier;
      }
    }
    
    // Si subió de nivel, bonus de monedas
    int levelBonus = 0;
    if (_level > oldLevel) {
      levelBonus = _level * 10; // Bonus por nivel
    }
    
    // Guardar cambios localmente
    await _saveLocalData();
    
    notifyListeners();
    
    // Agregar monedas si hay contexto disponible
    if (context != null) {
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      await coinProvider.addCoins(
        finalCoins.round() + levelBonus,
        reason: levelBonus > 0 
            ? 'Desafío completado + Subida de nivel' 
            : 'Desafío completado',
      );
    }
    
    // En una implementación real, sincronizaríamos con el backend
    // await _syncToServer();
  }

  // Completar lección con recompensas
  Future<void> completeLesson(String lessonId, {BuildContext? context}) async {
    final baseXp = 75.0;
    final baseCoins = 40.0;
    final oldLevel = _level;
    
    // Aplicar multiplicador de XP si hay potenciador activo
    double finalXp = baseXp;
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        finalXp *= boosterProvider.xpMultiplier;
      }
    }
    
    _xp += finalXp.round();
    
    // Verificar subida de nivel
    if (_xp >= _level * 100) {
      _level++;
    }
    
    // Aplicar multiplicador de monedas si hay potenciador activo
    double finalCoins = baseCoins;
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        finalCoins *= boosterProvider.coinMultiplier;
      }
    }
    
    int levelBonus = 0;
    if (_level > oldLevel) {
      levelBonus = _level * 15; // Bonus mayor por lecciones
    }
    
    // Guardar cambios localmente
    await _saveLocalData();
    
    notifyListeners();
    
    // Agregar monedas
    if (context != null) {
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      await coinProvider.addCoins(
        finalCoins.round() + levelBonus,
        reason: levelBonus > 0 
            ? 'Lección completada + Subida de nivel' 
            : 'Lección completada',
      );
    }
  }

  // Completar juego con recompensas especiales
  Future<void> completeGame(String gameId, int score, {BuildContext? context}) async {
    // Calcular XP basado en puntuación
    final baseXp = 100.0;
    final scoreBonus = (score * 0.1);
    double totalXp = baseXp + scoreBonus;
    final oldLevel = _level;
    
    // Aplicar multiplicador de XP si hay potenciador activo
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        totalXp *= boosterProvider.xpMultiplier;
      }
    }
    
    _xp += totalXp.round();
    
    // Verificar subida de nivel
    if (_xp >= _level * 100) {
      _level++;
    }
    
    // Calcular monedas (juegos dan más monedas)
    final baseCoins = 60.0;
    double coinBonus = (score * 0.05);
    double totalCoins = baseCoins + coinBonus;
    
    // Aplicar multiplicador de monedas si hay potenciador activo
    if (context != null) {
      final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
      if (boosterProvider.hasActiveBooster) {
        totalCoins *= boosterProvider.coinMultiplier;
      }
    }
    
    int levelBonus = 0;
    if (_level > oldLevel) {
      levelBonus = _level * 20; // Bonus aún mayor por juegos
    }
    
    // Guardar cambios localmente
    await _saveLocalData();
    
    notifyListeners();
    
    // Agregar monedas
    if (context != null) {
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      await coinProvider.addCoins(
        totalCoins.round() + levelBonus,
        reason: levelBonus > 0 
            ? 'Juego completado + Subida de nivel' 
            : 'Juego completado',
      );
    }
  }
  // Recargar datos del estudiante
  Future<void> refreshStudentData() async {
    await _loadStudentData();
  }

  // Método para sincronizar datos con el servidor (para implementación futura)
  Future<void> _syncToServer() async {
    try {
      // En una implementación real, aquí enviarías _level y _xp al servidor
      // await _studentService.updateProgress(_xp, _level);
      print('Sincronización con servidor - Nivel: $_level, XP: $_xp');
    } catch (e) {
      print('Error en sincronización: $e');
    }
  }

  // Limpiar datos locales (útil para logout)
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('student_level');
      await prefs.remove('student_xp');
      await prefs.remove('student_has_classroom');
      await prefs.remove('student_course_name');
      await prefs.remove('student_classroom_name');
      await prefs.remove('student_subjects');
      
      // Resetear valores
      _level = 1;
      _xp = 0;
      _hasClassroom = false;
      _courseName = null;
      _classroomName = null;
      _subjects = [];
      
      notifyListeners();
    } catch (e) {
      print('Error limpiando datos locales: $e');
    }
  }
  

  // Cambiar estado de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}