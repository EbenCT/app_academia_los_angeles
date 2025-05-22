// lib/providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/student_service.dart';
import '../models/subject_model.dart';

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