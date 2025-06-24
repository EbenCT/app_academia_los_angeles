// lib/providers/student_tracking_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/student_tracking_model.dart';
import '../services/student_tracking_service.dart';

class StudentTrackingProvider extends ChangeNotifier {
  late final StudentTrackingService _trackingService;
  
  bool _isLoading = false;
  String? _error;
  List<StudentTrackingModel> _students = [];
  StudentTrackingModel? _selectedStudent;
  int? _selectedClassroomId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StudentTrackingModel> get students => _students;
  StudentTrackingModel? get selectedStudent => _selectedStudent;
  int? get selectedClassroomId => _selectedClassroomId;

  // Constructor
  StudentTrackingProvider(GraphQLClient client) {
    _trackingService = StudentTrackingService(client);
  }

  // Cargar estudiantes de un aula específica
  Future<void> loadClassroomStudents(int classroomId) async {
    _setLoading(true);
    _error = null;
    _selectedClassroomId = classroomId;
    _selectedStudent = null; // Limpiar selección anterior
    
    try {
      _students = await _trackingService.getClassroomStudents(classroomId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _students = [];
      _setLoading(false);
    }
  }

  // Seleccionar un estudiante y cargar sus detalles
  Future<void> selectStudent(StudentTrackingModel student) async {
    _selectedStudent = student;
    notifyListeners();
    
    // Aquí podrías cargar más detalles si fuera necesario
    try {
      final detailedStudent = await _trackingService.getStudentDetails(student.id);
      if (detailedStudent != null) {
        _selectedStudent = detailedStudent;
        notifyListeners();
      }
    } catch (e) {
      // Si falla cargar detalles, mantener el estudiante básico
      print('Error cargando detalles del estudiante: $e');
    }
  }

  // Limpiar selección de estudiante
  void clearStudentSelection() {
    _selectedStudent = null;
    notifyListeners();
  }

  // Limpiar todos los datos
  void clearAllData() {
    _students = [];
    _selectedStudent = null;
    _selectedClassroomId = null;
    _error = null;
    notifyListeners();
  }

  // Refrescar datos actuales
  Future<void> refresh() async {
    if (_selectedClassroomId != null) {
      await loadClassroomStudents(_selectedClassroomId!);
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

  // Obtener estadísticas del aula
  Map<String, dynamic> getClassroomStats() {
    if (_students.isEmpty) {
      return {
        'totalStudents': 0,
        'averageProgress': 0,
        'activeStudents': 0,
        'averageTime': 0,
      };
    }

    final totalStudents = _students.length;
    final averageProgress = _students.map((s) => s.avance).reduce((a, b) => a + b) / totalStudents;
    final activeStudents = _students.where((s) => s.estado == 'activo').length;
    final averageTime = _students.map((s) => s.tiempoDedicado).reduce((a, b) => a + b) / totalStudents;

    return {
      'totalStudents': totalStudents,
      'averageProgress': averageProgress.round(),
      'activeStudents': activeStudents,
      'averageTime': averageTime.round(),
    };
  }
}