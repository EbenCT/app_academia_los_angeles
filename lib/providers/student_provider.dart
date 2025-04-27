// lib/providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  late final StudentService _studentService;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _studentData;
  bool _hasClassroom = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get studentData => _studentData;
  bool get hasClassroom => _hasClassroom;

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