// lib/services/lesson_progress_service_extension.dart
// Extensión para agregar funcionalidades faltantes a LessonProgressService

import 'package:shared_preferences/shared_preferences.dart';
import 'lesson_progress_service.dart';

/// Extensión para agregar métodos faltantes al LessonProgressService existente
class LessonProgressServiceExtension {
  
  /// Marcar una lección como completada
  static Future<void> markLessonCompleted(int lessonId, {int? subjectId}) async {
    try {
      print('✅ Marcando lección $lessonId como completada');
      
      // Si no se proporciona subjectId, lo inferimos (por ahora asumimos materia 1)
      final finalSubjectId = subjectId ?? 1;
      
      await _updateLessonStatus(
        lessonId: lessonId,
        subjectId: finalSubjectId,
        isCompleted: true,
        isUnlocked: true,
      );
      
      print('✅ Lección $lessonId marcada como completada exitosamente');
    } catch (e) {
      print('❌ Error marcando lección como completada: $e');
      throw e;
    }
  }

  /// Desbloquear una lección
  static Future<void> unlockLesson(int lessonId, {int? subjectId}) async {
    try {
      print('🔓 Desbloqueando lección $lessonId');
      
      final finalSubjectId = subjectId ?? 1;
      
      await _updateLessonStatus(
        lessonId: lessonId,
        subjectId: finalSubjectId,
        isUnlocked: true,
      );
      
      print('✅ Lección $lessonId desbloqueada exitosamente');
    } catch (e) {
      print('❌ Error desbloqueando lección: $e');
      throw e;
    }
  }

  /// Actualizar el estado de una lección específica
  static Future<void> _updateLessonStatus({
    required int lessonId,
    required int subjectId,
    bool? isCompleted,
    bool? isUnlocked,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${subjectId}_lessons';
      final progressJson = prefs.getStringList(subjectKey) ?? [];
      
      // Buscar si ya existe progreso para esta lección
      int existingIndex = -1;
      for (int i = 0; i < progressJson.length; i++) {
        final parts = progressJson[i].split('|');
        if (parts.isNotEmpty && int.tryParse(parts[0]) == lessonId) {
          existingIndex = i;
          break;
        }
      }
      
      if (existingIndex >= 0) {
        // Actualizar progreso existente
        final parts = progressJson[existingIndex].split('|');
        final updatedProgress = _createProgressString(
          lessonId: lessonId,
          title: parts.length > 1 ? parts[1] : 'Lección $lessonId',
          type: parts.length > 2 ? parts[2] : 'lesson',
          isUnlocked: isUnlocked ?? (parts.length > 3 ? parts[3] == 'true' : false),
          isCompleted: isCompleted ?? (parts.length > 4 ? parts[4] == 'true' : false),
          description: parts.length > 5 ? parts[5] : '',
        );
        
        progressJson[existingIndex] = updatedProgress;
      } else {
        // Crear nuevo progreso
        final baseLessons = LessonProgressService.getBaseLessonsForSubject(subjectId);
        final lessonData = baseLessons.firstWhere(
          (lesson) => lesson['id'] == lessonId,
          orElse: () => {'id': lessonId, 'title': 'Lección $lessonId', 'type': 'lesson'},
        );
        
        final newProgress = _createProgressString(
          lessonId: lessonId,
          title: lessonData['title'] ?? 'Lección $lessonId',
          type: lessonData['type'] ?? 'lesson',
          isUnlocked: isUnlocked ?? false,
          isCompleted: isCompleted ?? false,
          description: lessonData['description'] ?? '',
        );
        
        progressJson.add(newProgress);
      }
      
      // Guardar progreso actualizado
      await prefs.setStringList(subjectKey, progressJson);
      
      // Si completamos una lección, desbloquear la siguiente automáticamente
      if (isCompleted == true) {
        await _unlockNextLesson(lessonId, subjectId);
      }
      
    } catch (e) {
      print('❌ Error actualizando estado de lección: $e');
      throw e;
    }
  }

  /// Desbloquear la siguiente lección automáticamente
  static Future<void> _unlockNextLesson(int completedLessonId, int subjectId) async {
    try {
      final baseLessons = LessonProgressService.getBaseLessonsForSubject(subjectId);
      
      // Encontrar índice de la lección completada
      int currentIndex = -1;
      for (int i = 0; i < baseLessons.length; i++) {
        if (baseLessons[i]['id'] == completedLessonId) {
          currentIndex = i;
          break;
        }
      }
      
      // Si hay una siguiente lección, desbloquearla
      if (currentIndex >= 0 && currentIndex + 1 < baseLessons.length) {
        final nextLessonId = baseLessons[currentIndex + 1]['id'] as int;
        
        await _updateLessonStatus(
          lessonId: nextLessonId,
          subjectId: subjectId,
          isUnlocked: true,
        );
        
        print('🔓 Siguiente lección $nextLessonId desbloqueada automáticamente');
      }
    } catch (e) {
      print('⚠️ Error desbloqueando siguiente lección: $e');
      // No lanzamos el error para no afectar el flujo principal
    }
  }

  /// Crear string de progreso en el formato esperado
  static String _createProgressString({
    required int lessonId,
    required String title,
    required String type,
    required bool isUnlocked,
    required bool isCompleted,
    required String description,
  }) {
    return '$lessonId|$title|$type|$isUnlocked|$isCompleted|$description';
  }

  /// Obtener progreso de una lección específica
  static Future<Map<String, dynamic>?> getLessonProgress(int lessonId, int subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${subjectId}_lessons';
      final progressJson = prefs.getStringList(subjectKey) ?? [];
      
      for (String progressString in progressJson) {
        final parts = progressString.split('|');
        if (parts.isNotEmpty && int.tryParse(parts[0]) == lessonId) {
          return {
            'lessonId': lessonId,
            'title': parts.length > 1 ? parts[1] : 'Lección $lessonId',
            'type': parts.length > 2 ? parts[2] : 'lesson',
            'isUnlocked': parts.length > 3 ? parts[3] == 'true' : false,
            'isCompleted': parts.length > 4 ? parts[4] == 'true' : false,
            'description': parts.length > 5 ? parts[5] : '',
          };
        }
      }
      
      return null; // No se encontró progreso para esta lección
    } catch (e) {
      print('❌ Error obteniendo progreso de lección: $e');
      return null;
    }
  }

  /// Reiniciar progreso de una materia (útil para testing)
  static Future<void> resetSubjectProgress(int subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${subjectId}_lessons';
      await prefs.remove(subjectKey);
      print('🧹 Progreso de materia $subjectId reiniciado');
    } catch (e) {
      print('❌ Error reiniciando progreso: $e');
      throw e;
    }
  }

  /// Obtener estadísticas detalladas de progreso
  static Future<Map<String, dynamic>> getDetailedProgress(int subjectId) async {
    try {
      final basicProgress = await LessonProgressService.getSubjectProgress(subjectId);
      final prefs = await SharedPreferences.getInstance();
      final subjectKey = 'subject_${subjectId}_lessons';
      final progressJson = prefs.getStringList(subjectKey) ?? [];
      
      final now = DateTime.now();
      DateTime? lastActivity;
      
      // Buscar última actividad en SharedPreferences
      final lastActivityKey = 'last_activity_subject_$subjectId';
      final lastActivityTimestamp = prefs.getInt(lastActivityKey);
      if (lastActivityTimestamp != null) {
        lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityTimestamp);
      }
      
      return {
        ...basicProgress,
        'lastActivity': lastActivity?.toIso8601String(),
        'totalSavedLessons': progressJson.length,
        'daysSinceLastActivity': lastActivity != null 
            ? now.difference(lastActivity).inDays 
            : null,
      };
    } catch (e) {
      print('❌ Error obteniendo progreso detallado: $e');
      return await LessonProgressService.getSubjectProgress(subjectId);
    }
  }

  /// Actualizar timestamp de última actividad
  static Future<void> updateLastActivity(int subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityKey = 'last_activity_subject_$subjectId';
      await prefs.setInt(lastActivityKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('⚠️ Error actualizando última actividad: $e');
    }
  }
}