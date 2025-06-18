// lib/services/lesson_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_models.dart';

class LessonApiService {
  static const String baseUrl = 'https://tu-backend.com/api';
  
  /// Obtener temas de una materia específica
  static Future<List<Topic>> getTopicsBySubject(int subjectId) async {
    try {
      // TODO: Reemplazar con llamada real al backend
      // final response = await http.get(
      //   Uri.parse('$baseUrl/subjects/$subjectId/topics'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // if (response.statusCode == 200) {
      //   final List<dynamic> jsonData = json.decode(response.body);
      //   return jsonData.map((json) => Topic.fromJson(json)).toList();
      // } else {
      //   throw Exception('Error al cargar temas: ${response.statusCode}');
      // }
      
      // SIMULACIÓN - Remover cuando tengas el backend real
      await Future.delayed(Duration(milliseconds: 800)); // Simular latencia
      return _getSimulatedTopics(subjectId);
      
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener lecciones de un tema específico
  static Future<List<Lesson>> getLessonsByTopic(int topicId) async {
    try {
      // TODO: Reemplazar con llamada real al backend
      // final response = await http.get(
      //   Uri.parse('$baseUrl/topics/$topicId/lessons'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // if (response.statusCode == 200) {
      //   final List<dynamic> jsonData = json.decode(response.body);
      //   return jsonData.map((json) => Lesson.fromJson(json)).toList();
      // } else {
      //   throw Exception('Error al cargar lecciones: ${response.statusCode}');
      // }
      
      // SIMULACIÓN - Remover cuando tengas el backend real
      await Future.delayed(Duration(milliseconds: 1000)); // Simular latencia
      return _getSimulatedLessons(topicId);
      
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener una lección específica con todos sus ejercicios
  static Future<Lesson> getLessonWithExercises(int lessonId) async {
    try {
      // TODO: Reemplazar con llamada real al backend
      // final response = await http.get(
      //   Uri.parse('$baseUrl/lessons/$lessonId/exercises'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // if (response.statusCode == 200) {
      //   final Map<String, dynamic> jsonData = json.decode(response.body);
      //   return Lesson.fromJson(jsonData);
      // } else {
      //   throw Exception('Error al cargar lección: ${response.statusCode}');
      // }
      
      // SIMULACIÓN - Remover cuando tengas el backend real
      await Future.delayed(Duration(milliseconds: 600));
      return _getSimulatedLessonWithExercises(lessonId);
      
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener progreso del estudiante para un tema
  static Future<List<LessonProgress>> getLessonProgress(int studentId, int topicId) async {
    try {
      // TODO: Reemplazar con llamada real al backend
      // final response = await http.get(
      //   Uri.parse('$baseUrl/students/$studentId/topics/$topicId/progress'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      
      // if (response.statusCode == 200) {
      //   final List<dynamic> jsonData = json.decode(response.body);
      //   return jsonData.map((json) => LessonProgress.fromJson(json)).toList();
      // } else {
      //   throw Exception('Error al cargar progreso: ${response.statusCode}');
      // }
      
      // SIMULACIÓN - Remover cuando tengas el backend real
      await Future.delayed(Duration(milliseconds: 400));
      return _getSimulatedProgress(studentId, topicId);
      
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Guardar progreso de ejercicio
  static Future<void> saveExerciseProgress(StudentExerciseProgress progress) async {
    try {
      // TODO: Reemplazar con llamada real al backend
      // final response = await http.post(
      //   Uri.parse('$baseUrl/students/exercise-progress'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(progress.toJson()),
      // );
      
      // if (response.statusCode != 200 && response.statusCode != 201) {
      //   throw Exception('Error al guardar progreso: ${response.statusCode}');
      // }
      
      // SIMULACIÓN - Remover cuando tengas el backend real
      await Future.delayed(Duration(milliseconds: 300));
      print('Progreso guardado: Ejercicio ${progress.exerciseId}, Error: ${progress.error}');
      
    } catch (e) {
      throw Exception('Error guardando progreso: $e');
    }
  }

  // ============= DATOS SIMULADOS (REMOVER EN PRODUCCIÓN) =============
  
  static List<Topic> _getSimulatedTopics(int subjectId) {
    // Simular diferentes temas según la materia
    if (subjectId == 1) { // Matemáticas
      return [
        Topic(id: 1, name: 'Introducción a los números enteros', xpReward: 100, subjectId: 1),
        Topic(id: 2, name: 'Operaciones básicas', xpReward: 150, subjectId: 1),
        Topic(id: 3, name: 'Problemas avanzados', xpReward: 200, subjectId: 1),
      ];
    }
    return [];
  }

  static List<Lesson> _getSimulatedLessons(int topicId) {
    if (topicId == 1) { // Números enteros
      return [
        Lesson(
          id: 1,
          title: '¿Qué son los números enteros?',
          content: 'Los números enteros incluyen los números negativos, el cero y los positivos.',
          imgLink: null,
          topicId: 1,
        ),
        Lesson(
          id: 2,
          title: 'La recta numérica',
          content: 'Aprende a ubicar números enteros en la recta numérica.',
          imgLink: null,
          topicId: 1,
        ),
        Lesson(
          id: 3,
          title: 'Aplicaciones prácticas',
          content: 'Descubre cómo usar los números enteros en la vida real.',
          imgLink: null,
          topicId: 1,
        ),
      ];
    }
    return [];
  }

  static Lesson _getSimulatedLessonWithExercises(int lessonId) {
    if (lessonId == 1) {
      // Esta es la simulación de la lección "números enteros" que estaba hardcodeada
      return Lesson(
        id: 1,
        title: '¿Qué son los números enteros?',
        content: 'Los números enteros incluyen los números negativos, el cero y los positivos.',
        imgLink: null,
        topicId: 1,
        exercises: [
          Exercise(
            id: 1,
            severity: 'easy',
            question: 'Selecciona todos los números enteros:',
            type: 1, // Tipo 1: respuesta correcta
            coins: 10,
            lessonId: 1,
            options: [
              ExerciseOption(id: 1, text: '-5', isCorrect: true, index: 0, exerciseId: 1),
              ExerciseOption(id: 2, text: '3.14', isCorrect: false, index: 0, exerciseId: 1),
              ExerciseOption(id: 3, text: '0', isCorrect: true, index: 0, exerciseId: 1),
              ExerciseOption(id: 4, text: '10', isCorrect: true, index: 0, exerciseId: 1),
              ExerciseOption(id: 5, text: '-2.5', isCorrect: false, index: 0, exerciseId: 1),
              ExerciseOption(id: 6, text: '½', isCorrect: false, index: 0, exerciseId: 1),
              ExerciseOption(id: 7, text: '-8', isCorrect: true, index: 0, exerciseId: 1),
              ExerciseOption(id: 8, text: '√2', isCorrect: false, index: 0, exerciseId: 1),
              ExerciseOption(id: 9, text: '6', isCorrect: true, index: 0, exerciseId: 1),
            ],
          ),
          Exercise(
            id: 2,
            severity: 'medium',
            question: 'Ordena estos números enteros de menor a mayor:',
            type: 2, // Tipo 2: ordenar opciones
            coins: 15,
            lessonId: 1,
            options: [
              ExerciseOption(id: 10, text: '-7', isCorrect: true, index: 1, exerciseId: 2),
              ExerciseOption(id: 11, text: '-3', isCorrect: true, index: 2, exerciseId: 2),
              ExerciseOption(id: 12, text: '0', isCorrect: true, index: 3, exerciseId: 2),
              ExerciseOption(id: 13, text: '5', isCorrect: true, index: 4, exerciseId: 2),
              ExerciseOption(id: 14, text: '10', isCorrect: true, index: 5, exerciseId: 2),
            ],
          ),
        ],
      );
    } else if (lessonId == 2) {
      return Lesson(
        id: 2,
        title: 'La recta numérica',
        content: 'Aprende a ubicar números enteros en la recta numérica.',
        imgLink: null,
        topicId: 1,
        exercises: [
          Exercise(
            id: 3,
            severity: 'easy',
            question: '¿Qué número está entre -3 y -1?',
            type: 1,
            coins: 10,
            lessonId: 2,
            options: [
              ExerciseOption(id: 15, text: '-4', isCorrect: false, index: 0, exerciseId: 3),
              ExerciseOption(id: 16, text: '-2', isCorrect: true, index: 0, exerciseId: 3),
              ExerciseOption(id: 17, text: '0', isCorrect: false, index: 0, exerciseId: 3),
              ExerciseOption(id: 18, text: '2', isCorrect: false, index: 0, exerciseId: 3),
            ],
          ),
        ],
      );
    }
    
    // Lección por defecto
    return Lesson(
      id: lessonId,
      title: 'Lección ${lessonId}',
      content: 'Contenido de la lección ${lessonId}',
      imgLink: null,
      topicId: 1,
      exercises: [],
    );
  }

  static List<LessonProgress> _getSimulatedProgress(int studentId, int topicId) {
    // Simular progreso del estudiante
    return [
      LessonProgress(lessonId: 1, isUnlocked: true, isCompleted: false, progressPercentage: 0.0),
      LessonProgress(lessonId: 2, isUnlocked: false, isCompleted: false, progressPercentage: 0.0),
      LessonProgress(lessonId: 3, isUnlocked: false, isCompleted: false, progressPercentage: 0.0),
    ];
  }
}