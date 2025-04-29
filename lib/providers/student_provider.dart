// lib/providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/student_service.dart';
import '../models/course_model.dart';

class StudentProvider extends ChangeNotifier {
  late final StudentService _studentService;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _studentData;
  bool _hasClassroom = false;
  int _level = 1;
  int _xp = 0;
  int _streakDays = 0; // Días consecutivos de actividad
  List<Map<String, dynamic>> _achievements = [];
  List<CourseModel> _courses = [];
  Map<String, double> _courseProgress = {}; // Mapa de progreso por curso

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get studentData => _studentData;
  bool get hasClassroom => _hasClassroom;
  int get level => _level;
  int get xp => _xp;
  int get streakDays => _streakDays;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<CourseModel> get courses => _courses;
  Map<String, double> get courseProgress => _courseProgress;

  // Constructor
  StudentProvider(GraphQLClient client) {
    _studentService = StudentService(client);
    _loadStudentData();
  }

  // Cargar datos del estudiante
  Future<void> _loadStudentData() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _studentService.getStudentInfo();
      _studentData = data;
      _hasClassroom = data['classroom'] != null;
      
      // Extraer nivel y XP
      _level = data['level'] ?? 1;
      _xp = data['xp'] ?? 0;
      
      // Cargar cursos si hay un aula asignada
      if (_hasClassroom && data['classroom'] != null) {
        await _loadCoursesData(data['classroom']['course']['id']);
      }
      
      // Cargar logros (si están disponibles en la API)
      await _loadAchievements();
      
      // Cargar racha de días (podría ser un valor simulado por ahora)
      _streakDays = 5; // Por defecto 5 días, hasta que el backend lo proporcione
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Cargar información de cursos
  Future<void> _loadCoursesData(int courseId) async {
    try {
      // Obtener información detallada del curso del estudiante
      final courseDetails = await _studentService.getCourseDetails(courseId);
      
      // Si hay materias en el curso, las convertimos a CourseModel
      if (courseDetails != null && courseDetails['subjects'] != null) {
        final subjects = courseDetails['subjects'] as List<dynamic>;
        
        _courses = subjects.map((subject) {
          final id = subject['id'] as int;
          final name = subject['name'] as String;
          final description = subject['description'] as String?;
          
          // Asignar un progreso aleatorio por ahora (entre 0.1 y 0.9)
          // Esto debería venir del backend en el futuro
          _courseProgress[name] = (id % 9 + 1) / 10;
          
          return CourseModel(
            id: id,
            title: name,
            description: description,
          );
        }).toList();
      }
    } catch (e) {
      print('Error al cargar datos de cursos: $e');
      // No establecemos error para que no interrumpa la carga del resto de datos
    }
  }

  // Cargar logros del estudiante
  Future<void> _loadAchievements() async {
    try {
      // En el futuro, esto vendría del backend
      // Por ahora, usamos datos de muestra
      _achievements = [
        {
          'title': 'Explorador espacial',
          'description': 'Completaste tu primera misión',
          'icon': 'rocket_launch',
          'unlocked': true,
        },
        {
          'title': 'Matemático junior',
          'description': 'Completaste 10 ejercicios de matemáticas',
          'icon': 'calculate',
          'unlocked': _level >= 2, // Desbloqueo basado en nivel
        },
        {
          'title': 'Científico curioso',
          'description': 'Realizaste tu primer experimento',
          'icon': 'science',
          'unlocked': _level >= 3,
        },
      ];
    } catch (e) {
      print('Error al cargar logros: $e');
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
        await _loadCoursesData(data['classroom']['course']['id']);
        await _loadAchievements();
      }
      
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

  // Completar un desafío (simulación para actualizar puntos)
  Future<void> completeChallenge(int pointsEarned) async {
    _xp += pointsEarned;
    
    // Lógica simple para subir de nivel
    if (_xp >= _level * 100) {
      _level++;
      
      // Verificar si se desbloquean nuevos logros
      await _loadAchievements();
    }
    
    notifyListeners();
    
    // En una implementación real, sincronizaríamos con el backend
    // await _studentService.updateProgress(_xp, _level);
  }

  // Recargar datos del estudiante
  Future<void> refreshStudentData() async {
    await _loadStudentData();
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