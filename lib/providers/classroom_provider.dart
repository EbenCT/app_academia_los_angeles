// lib/providers/classroom_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/classroom_model.dart';
import '../models/course_model.dart';
import '../services/classroom_service.dart';

class ClassroomProvider extends ChangeNotifier {
  late final ClassroomService _classroomService;
  
  bool _isLoading = false;
  String? _error;
  List<ClassroomModel> _classrooms = [];
  List<CourseModel> _courses = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassroomModel> get classrooms => _classrooms;
  List<CourseModel> get courses => _courses;
  
  // Constructor
  ClassroomProvider(GraphQLClient client) {
    _classroomService = ClassroomService(client);
    _loadInitialData();
  }
  
  // Cargar datos iniciales
  Future<void> _loadInitialData() async {
    await fetchTeacherClassrooms();
    await fetchCourses();
  }
  
  // Obtener aulas del profesor
  Future<void> fetchTeacherClassrooms() async {
    _setLoading(true);
    _error = null;
    
    try {
      _classrooms = await _classroomService.getTeacherClassrooms();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  // Obtener cursos disponibles
  Future<void> fetchCourses() async {
    _setLoading(true);
    _error = null;
    
    try {
      _courses = await _classroomService.getCourses();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  // Crear nueva aula
  Future<bool> createClassroom(String name, String? description, int courseId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final newClassroom = await _classroomService.createClassroom(name, description, courseId);
      _classrooms.add(newClassroom);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
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