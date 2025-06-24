// lib/services/adaptive_exercise_service.dart - Versión con debug mejorado
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/lesson_models.dart';

class AdaptiveExerciseService {
  final GraphQLClient _client;

  AdaptiveExerciseService(this._client);

  // Query para obtener ejercicios adaptativos - ACTUALIZADO para requerir topicId
  final String _getAdaptiveExercisesQuery = r'''
  query GetAdaptativeExercises($topicId: Int!) {
    getAdaptativeExercises(topicId: $topicId) {
      id
      question
      severity
      type
      coins
      options {
        id
        text
        is_correct
        index
      }
    }
  }
  ''';

  /// Obtiene ejercicios adaptativos basados en el conocimiento del estudiante
  /// ACTUALIZADO: Ahora requiere topicId
  Future<List<Exercise>> getAdaptiveExercises({int? topicId}) async {
    try {
      print('🔍 [AdaptiveService] Iniciando consulta de ejercicios adaptativos para topic: $topicId');
      
      if (topicId == null) {
        print('⚠️ [AdaptiveService] No se proporcionó topicId, no se pueden obtener ejercicios adaptativos');
        return [];
      }
      
      final result = await _client.query(
        QueryOptions(
          document: gql(_getAdaptiveExercisesQuery),
          variables: {
            'topicId': topicId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      print('🔍 [AdaptiveService] Resultado de la consulta: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdaptiveService] Error en la consulta: ${result.exception}');
        throw Exception(_getErrorMessage(result.exception));
      }
      
      final exercisesData = result.data?['getAdaptativeExercises'] as List?;
      
      if (exercisesData == null) {
        print('⚠️ [AdaptiveService] No se encontraron datos de ejercicios adaptativos para topic $topicId');
        return [];
      }
      
      print('🔍 [AdaptiveService] Datos crudos encontrados: ${exercisesData.length} ejercicios para topic $topicId');
      print('🔍 [AdaptiveService] Primer ejercicio: ${exercisesData.isNotEmpty ? exercisesData.first : 'N/A'}');
      
      final exercises = <Exercise>[];
      
      for (int i = 0; i < exercisesData.length; i++) {
        try {
          final exerciseJson = exercisesData[i] as Map<String, dynamic>;
          print('🔍 [AdaptiveService] Procesando ejercicio $i: ${exerciseJson['id']} - ${exerciseJson['question']}');
          
          // Verificar que el ejercicio tenga opciones
          final optionsData = exerciseJson['options'] as List?;
          if (optionsData == null || optionsData.isEmpty) {
            print('⚠️ [AdaptiveService] Ejercicio ${exerciseJson['id']} no tiene opciones, omitiendo');
            continue;
          }
          
          print('🔍 [AdaptiveService] Ejercicio ${exerciseJson['id']} tiene ${optionsData.length} opciones');
          
          final exercise = Exercise.fromJson(exerciseJson);
          exercises.add(exercise);
          
          print('✅ [AdaptiveService] Ejercicio ${exercise.id} procesado correctamente');
        } catch (e) {
          print('❌ [AdaptiveService] Error procesando ejercicio $i: $e');
          print('🔍 [AdaptiveService] Datos del ejercicio problemático: ${exercisesData[i]}');
        }
      }
      
      print('✅ [AdaptiveService] Procesamiento completado: ${exercises.length} ejercicios válidos para topic $topicId');
      
      return exercises;
    } catch (e) {
      print('❌ [AdaptiveService] Error general: $e');
      throw Exception('Error al obtener ejercicios adaptativos: $e');
    }
  }

  /// Verifica si el estudiante debe recibir ejercicios adaptativos
  /// (al completar todas las lecciones del topic)
  static bool shouldUnlockAdaptiveExercises(int completedLessons, int totalLessons) {
    return completedLessons == totalLessons && totalLessons > 0;
  }

  /// Obtiene el número de ejercicios adaptativos disponibles para desbloquear
  static int getAdaptiveUnlockCount(int completedLessons) {
    return (completedLessons / 5).floor();
  }

  // Extraer mensaje de error
  String _getErrorMessage(OperationException? exception) {
    if (exception == null) return 'Error desconocido';
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    if (exception.linkException != null) {
      return 'Error de conexión al servidor';
    }
    return exception.toString();
  }
}