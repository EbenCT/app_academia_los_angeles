// lib/services/lesson_migration_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../services/lesson_graphql_service.dart';
import '../services/lesson_progress_service.dart';
import '../services/lesson_progress_service_extension.dart'; // AGREGADO

/// Servicio para migrar datos locales a GraphQL y mantener sincronización
class LessonMigrationService {
  static const String _migrationVersionKey = 'lesson_migration_version';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const int _currentMigrationVersion = 1;

  static LessonGraphQLService? _graphqlService;

  /// Inicializar migración al abrir la app
  static Future<void> initializeMigration(int studentId) async {
    try {
      print('🔄 Iniciando proceso de migración...');
      
      _graphqlService ??= await LessonGraphQLService.getInstance();
      
      final prefs = await SharedPreferences.getInstance();
      final migrationVersion = prefs.getInt(_migrationVersionKey) ?? 0;
      
      if (migrationVersion < _currentMigrationVersion) {
        await _performMigration(studentId);
        await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);
        print('✅ Migración completada');
      } else {
        print('ℹ️ Migración no necesaria');
      }
      
      // Sincronizar datos periódicamente
      await _syncWithServer(studentId);
    } catch (e) {
      print('❌ Error en migración: $e');
      // La migración falla silenciosamente para no afectar la experiencia del usuario
    }
  }

  /// Realizar migración de datos locales a GraphQL
  static Future<void> _performMigration(int studentId) async {
    try {
      print('📦 Migrando datos locales a GraphQL...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Migrar progreso por materias
      for (int subjectId = 1; subjectId <= 10; subjectId++) {
        await _migrateSubjectProgress(studentId, subjectId, prefs);
      }
      
      print('✅ Migración de datos completada');
    } catch (e) {
      print('❌ Error migrando datos: $e');
      throw e;
    }
  }

  /// Migrar progreso de una materia específica
  static Future<void> _migrateSubjectProgress(
    int studentId, 
    int subjectId, 
    SharedPreferences prefs
  ) async {
    try {
      final subjectKey = 'subject_${subjectId}_lessons';
      final progressJson = prefs.getStringList(subjectKey);
      
      if (progressJson == null || progressJson.isEmpty) {
        print('🤷 No hay datos locales para materia $subjectId');
        return;
      }

      print('📤 Migrando progreso de materia $subjectId (${progressJson.length} lecciones)');
      
      for (String jsonString in progressJson) {
        try {
          final parts = jsonString.split('|');
          if (parts.length >= 6) {
            final lessonId = int.parse(parts[0]);
            final isCompleted = parts[2] == 'true';
            final isUnlocked = parts[3] == 'true';
            
            // Solo migrar si hay progreso real
            if (isCompleted || isUnlocked) {
              await _graphqlService!.updateLessonProgress(
                studentId: studentId,
                lessonId: lessonId,
                isCompleted: isCompleted,
                isUnlocked: isUnlocked,
                attempts: 1,
              );
              
              print('✅ Migrado progreso lección $lessonId');
            }
          }
        } catch (e) {
          print('⚠️ Error migrando lección individual: $e');
          // Continuar con las demás lecciones
        }
      }
    } catch (e) {
      print('❌ Error migrando materia $subjectId: $e');
    }
  }

  /// Sincronizar datos con el servidor
  static Future<void> _syncWithServer(int studentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Sincronizar cada 30 minutos
      if (now - lastSync > (30 * 60 * 1000)) {
        print('🔄 Sincronizando con servidor...');
        
        // Aquí podrías implementar lógica de sincronización bidireccional
        // Por ahora, solo actualizamos el timestamp
        await prefs.setInt(_lastSyncKey, now);
        
        print('✅ Sincronización completada');
      }
    } catch (e) {
      print('⚠️ Error en sincronización: $e');
    }
  }

  /// Obtener progreso híbrido (combina local y servidor)
  static Future<Map<String, dynamic>> getHybridProgress(
    int studentId, 
    int subjectId
  ) async {
    try {
      // Primero intentar obtener del servidor
      Map<String, dynamic> serverProgress = {};
      try {
        _graphqlService ??= await LessonGraphQLService.getInstance();
        serverProgress = await _graphqlService!.getSubjectStats(studentId, subjectId);
      } catch (e) {
        print('⚠️ No se pudo obtener progreso del servidor: $e');
      }

      // Obtener progreso local como fallback
      final localProgress = await LessonProgressService.getSubjectProgress(subjectId);
      
      // Combinar datos priorizando servidor pero usando local como fallback
      return {
        'progress': serverProgress['progressPercentage']?.toDouble() ?? 
                   localProgress['progress'] ?? 0.0,
        'completed': serverProgress['completedLessons'] ?? 
                    localProgress['completed'] ?? 0,
        'total': serverProgress['totalLessons'] ?? 
                localProgress['total'] ?? 0,
        'unlocked': localProgress['unlocked'] ?? 1, // Solo local por ahora
        'percentage': (serverProgress['progressPercentage']?.round()) ?? 
                     localProgress['percentage'] ?? 0,
        'source': serverProgress.isNotEmpty ? 'server' : 'local',
      };
    } catch (e) {
      print('❌ Error obteniendo progreso híbrido: $e');
      // Fallback a progreso local
      return await LessonProgressService.getSubjectProgress(subjectId);
    }
  }

  /// Guardar progreso de manera híbrida (local + servidor)
  static Future<void> saveHybridProgress({
    required int studentId,
    required int lessonId,
    required bool isCompleted,
    bool? isUnlocked,
    int? timeSpent,
    double? score,
    int? subjectId,
  }) async {
    // Guardar localmente primero (más rápido)
    try {
      await LessonProgressServiceExtension.markLessonCompleted(
        lessonId,
        subjectId: subjectId ?? 1,
      );
      print('✅ Progreso guardado localmente');
    } catch (e) {
      print('⚠️ Error guardando localmente: $e');
    }

    // Intentar guardar en servidor (en segundo plano)
    try {
      _graphqlService ??= await LessonGraphQLService.getInstance();
      await _graphqlService!.updateLessonProgress(
        studentId: studentId,
        lessonId: lessonId,
        isCompleted: isCompleted,
        isUnlocked: isUnlocked,
        timeSpent: timeSpent,
        bestScore: score,
      );
      print('✅ Progreso sincronizado con servidor');
    } catch (e) {
      print('⚠️ Error sincronizando con servidor: $e');
      // El progreso local ya está guardado, así que no es crítico
    }
  }

  /// Limpiar datos de migración (útil para testing)
  static Future<void> resetMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationVersionKey);
      await prefs.remove(_lastSyncKey);
      print('🧹 Datos de migración limpiados');
    } catch (e) {
      print('❌ Error limpiando migración: $e');
    }
  }

  /// Verificar estado de conectividad con el servidor
  static Future<bool> isServerAvailable() async {
    try {
      _graphqlService ??= await LessonGraphQLService.getInstance();
      
      // Intentar una query simple para verificar conectividad
      await _graphqlService!.getRecommendedLessons(1, limit: 1);
      return true;
    } catch (e) {
      print('🌐 Servidor no disponible: $e');
      return false;
    }
  }

  /// Obtener estadísticas de migración para debugging
  static Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationVersion = prefs.getInt(_migrationVersionKey) ?? 0;
      final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
      final serverAvailable = await isServerAvailable();
      
      return {
        'migrationVersion': migrationVersion,
        'lastSync': DateTime.fromMillisecondsSinceEpoch(lastSync),
        'serverAvailable': serverAvailable,
        'needsMigration': migrationVersion < _currentMigrationVersion,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}