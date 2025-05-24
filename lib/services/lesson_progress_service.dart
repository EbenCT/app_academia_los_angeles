// lib/services/lesson_progress_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LessonProgressService {
  static const Map<int, List<Map<String, dynamic>>> _subjectLessonsMap = {
    // Aquí definimos las lecciones base para cada materia
    // En el futuro esto podría venir del servidor
    1: [ // Matemáticas (ejemplo)
      {'id': 1, 'title': 'Introducción a los números enteros', 'type': 'lesson'},
      {'id': 2, 'title': 'Rescate de alturas', 'type': 'game'},
      {'id': 3, 'title': 'Operaciones con enteros', 'type': 'lesson'},
      {'id': 4, 'title': 'Batalla matemática', 'type': 'game'},
    ],
    2: [ // Ciencias (ejemplo)
      {'id': 1, 'title': 'El método científico', 'type': 'lesson'},
      {'id': 2, 'title': 'Experimento virtual', 'type': 'game'},
      {'id': 3, 'title': 'Estados de la materia', 'type': 'lesson'},
    ],
    3: [ // Lenguaje (ejemplo)
      {'id': 1, 'title': 'Ortografía básica', 'type': 'lesson'},
      {'id': 2, 'title': 'Aventura de palabras', 'type': 'game'},
    ],
    // Agregar más materias según necesites
  };

  /// Obtiene el progreso de una materia específica
  static Future<Map<String, dynamic>> getSubjectProgress(int subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${subjectId}_lessons';
      final progressJson = prefs.getStringList(subjectKey) ?? [];

      // Obtener lecciones base para esta materia
      final baseLessons = _subjectLessonsMap[subjectId] ?? [];
      final totalLessons = baseLessons.length;

      if (totalLessons == 0) {
        return {
          'progress': 0.0,
          'completed': 0,
          'total': 0,
          'unlocked': 1,
          'percentage': 0,
        };
      }

      int completed = 0;
      int unlocked = 1; // La primera siempre está desbloqueada

      if (progressJson.isNotEmpty) {
        // Contar lecciones completadas y desbloqueadas
        for (String lessonString in progressJson) {
          final parts = lessonString.split('|');
          if (parts.length >= 5) {
            final isUnlocked = parts[3] == 'true';
            final isCompleted = parts[4] == 'true';
            
            if (isCompleted) completed++;
            if (isUnlocked) unlocked++;
          }
        }
        // Evitar contar duplicados en unlocked
        unlocked = unlocked > totalLessons ? totalLessons : unlocked;
      }

      final progress = completed / totalLessons;
      final percentage = (progress * 100).round();

      return {
        'progress': progress,
        'completed': completed,
        'total': totalLessons,
        'unlocked': unlocked,
        'percentage': percentage,
      };
    } catch (e) {
      print('Error calculando progreso para materia $subjectId: $e');
      return {
        'progress': 0.0,
        'completed': 0,
        'total': _subjectLessonsMap[subjectId]?.length ?? 0,
        'unlocked': 1,
        'percentage': 0,
      };
    }
  }

  /// Obtiene el progreso de todas las materias
  static Future<Map<int, Map<String, dynamic>>> getAllSubjectsProgress(List<dynamic> subjects) async {
    final Map<int, Map<String, dynamic>> allProgress = {};
    
    for (var subject in subjects) {
      final subjectId = subject.id as int;
      allProgress[subjectId] = await getSubjectProgress(subjectId);
    }
    
    return allProgress;
  }

  /// Calcula el progreso general de todas las materias
  static Future<Map<String, dynamic>> getOverallProgress(List<dynamic> subjects) async {
    if (subjects.isEmpty) {
      return {
        'averageProgress': 0.0,
        'totalCompleted': 0,
        'totalLessons': 0,
        'percentage': 0,
      };
    }

    final allProgress = await getAllSubjectsProgress(subjects);
    
    int totalCompleted = 0;
    int totalLessons = 0;
    double totalProgress = 0.0;

    for (var progress in allProgress.values) {
      totalCompleted += progress['completed'] as int;
      totalLessons += progress['total'] as int;
      totalProgress += progress['progress'] as double;
    }

    final averageProgress = totalProgress / subjects.length;
    final percentage = (averageProgress * 100).round();

    return {
      'averageProgress': averageProgress,
      'totalCompleted': totalCompleted,
      'totalLessons': totalLessons,
      'percentage': percentage,
    };
  }

  /// Obtiene las lecciones base para una materia
  static List<Map<String, dynamic>> getBaseLessonsForSubject(int subjectId) {
    return _subjectLessonsMap[subjectId] ?? [];
  }

  /// Verifica si una materia tiene lecciones definidas
  static bool hasLessons(int subjectId) {
    return _subjectLessonsMap.containsKey(subjectId) && 
           _subjectLessonsMap[subjectId]!.isNotEmpty;
  }

  /// Agrega una nueva materia con sus lecciones (para uso futuro)
  static void addSubjectLessons(int subjectId, List<Map<String, dynamic>> lessons) {
    // En una implementación real, esto podría sincronizar con el servidor
    print('Agregando lecciones para materia $subjectId: ${lessons.length} lecciones');
  }
}