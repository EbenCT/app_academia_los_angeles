// lib/adapters/lesson_screen_adapter.dart

import 'package:flutter/material.dart';
import '../models/lesson_models.dart';
import '../services/lesson_migration_service.dart';
import '../services/lesson_graphql_service.dart';
import '../services/lesson_progress_service.dart';
import '../services/lesson_progress_service_extension.dart'; // AGREGADO
import '../providers/student_provider.dart';
import 'package:provider/provider.dart';

/// Adaptador para facilitar la transición de las pantallas existentes a GraphQL
class LessonScreenAdapter {
  
  /// Obtener lecciones con fallback automático
  static Future<List<Lesson>> getLessonsWithFallback(int topicId) async {
    try {
      // Intentar obtener del nuevo servicio GraphQL
      final graphqlService = await LessonGraphQLService.getInstance();
      final lessons = await graphqlService.getLessonsByTopic(topicId);
      
      if (lessons.isNotEmpty) {
        return lessons;
      }
    } catch (e) {
      print('⚠️ GraphQL no disponible, usando fallback: $e');
    }
    
    // Fallback a datos locales estáticos si es necesario
    return _getFallbackLessons(topicId);
  }

  /// Obtener progreso híbrido para la UI
  static Future<Map<String, dynamic>> getProgressForUI(
    BuildContext context,
    int subjectId,
  ) async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = _getStudentId(studentProvider);
      
      if (studentId > 0) {
        return await LessonMigrationService.getHybridProgress(studentId, subjectId);
      }
    } catch (e) {
      print('⚠️ Error obteniendo progreso híbrido: $e');
    }
    
    // Fallback a servicio local
    return await LessonProgressService.getSubjectProgress(subjectId);
  }

  /// Completar lección con sincronización automática
  static Future<void> completeLessonWithSync(
    BuildContext context,
    int lessonId, {
    int? timeSpent,
    double? score,
    int? subjectId,
  }) async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = _getStudentId(studentProvider);
      
      if (studentId > 0) {
        // Usar sistema híbrido
        await LessonMigrationService.saveHybridProgress(
          studentId: studentId,
          lessonId: lessonId,
          isCompleted: true,
          isUnlocked: true,
          timeSpent: timeSpent,
          score: score,
        );
      } else {
        // Fallback a sistema local usando la extensión
        await LessonProgressServiceExtension.markLessonCompleted(
          lessonId, 
          subjectId: subjectId,
        );
      }
    } catch (e) {
      print('❌ Error completando lección: $e');
      // Intentar al menos guardar localmente
      try {
        await LessonProgressServiceExtension.markLessonCompleted(
          lessonId,
          subjectId: subjectId,
        );
      } catch (localError) {
        print('💥 Error crítico guardando progreso: $localError');
        rethrow;
      }
    }
  }

  /// Widget para mostrar estado de conexión (opcional para debugging)
  static Widget buildConnectionStatus() {
    return FutureBuilder<bool>(
      future: LessonMigrationService.isServerAvailable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        final isConnected = snapshot.data ?? false;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
                color: isConnected ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'En línea' : 'Sin conexión',
                style: TextStyle(
                  fontSize: 12,
                  color: isConnected ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Inicializar migración automática al abrir una pantalla
  static Future<void> initializeForScreen(BuildContext context) async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = _getStudentId(studentProvider);
      
      if (studentId > 0) {
        // Inicializar migración en segundo plano
        LessonMigrationService.initializeMigration(studentId).catchError((e) {
          print('⚠️ Error en migración automática: $e');
        });
      }
    } catch (e) {
      print('⚠️ Error inicializando pantalla: $e');
    }
  }

  /// Obtener temas con fallback
  static Future<List<Topic>> getTopicsWithFallback(int subjectId) async {
    try {
      final graphqlService = await LessonGraphQLService.getInstance();
      final topics = await graphqlService.getTopicsBySubject(subjectId);
      
      if (topics.isNotEmpty) {
        return topics;
      }
    } catch (e) {
      print('⚠️ GraphQL no disponible para temas, usando fallback: $e');
    }
    
    // Fallback a datos estáticos
    return _getFallbackTopics(subjectId);
  }

  /// Widget para manejo de errores con retry
  static Widget buildErrorWidget(
    String message,
    VoidCallback onRetry, {
    bool showRetry = true,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget de loading mejorado
  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Métodos privados para fallbacks y utilidades

  static int _getStudentId(StudentProvider provider) {
    // Aquí puedes implementar la lógica para obtener el ID del estudiante
    // Por ahora retornamos un ID por defecto
    return provider.level > 0 ? 1 : 0; // Simplificado
  }

  static List<Lesson> _getFallbackLessons(int topicId) {
    // Datos de fallback basados en el sistema actual
    if (topicId == 1) {
      return [
        Lesson(
          id: 1,
          title: 'Introducción a los números enteros',
          content: 'Los números enteros incluyen los números negativos, el cero y los positivos.',
          topicId: 1,
        ),
        Lesson(
          id: 2,
          title: 'La recta numérica',
          content: 'Aprende a ubicar números enteros en la recta numérica.',
          topicId: 1,
        ),
        Lesson(
          id: 3,
          title: 'Aplicaciones prácticas',
          content: 'Descubre cómo usar los números enteros en la vida real.',
          topicId: 1,
        ),
      ];
    }
    return [];
  }

  static List<Topic> _getFallbackTopics(int subjectId) {
    // Datos de fallback basados en el sistema actual
    if (subjectId == 1) {
      return [
        Topic(
          id: 1,
          name: 'Introducción a los números enteros',
          xpReward: 100,
          subjectId: 1,
        ),
        Topic(
          id: 2,
          name: 'Operaciones básicas',
          xpReward: 150,
          subjectId: 1,
        ),
        Topic(
          id: 3,
          name: 'Problemas avanzados',
          xpReward: 200,
          subjectId: 1,
        ),
      ];
    }
    return [];
  }
}