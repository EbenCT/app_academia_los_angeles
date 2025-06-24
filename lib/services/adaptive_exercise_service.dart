// lib/services/adaptive_exercise_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/lesson_models.dart';

class AdaptiveExerciseService {
  final GraphQLClient _client;

  AdaptiveExerciseService(this._client);

  // Query para obtener ejercicios adaptativos
  final String _getAdaptiveExercisesQuery = r'''
  query GetAdaptativeExercises {
    getAdaptativeExercises {
      question
      severity
      type
      options {
        index
        id
        is_correct
        text
      }
      id
      coins
    }
  }
  ''';

  /// Obtiene ejercicios adaptativos basados en el conocimiento del estudiante
  Future<List<Exercise>> getAdaptiveExercises() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getAdaptiveExercisesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      
      final exercisesData = result.data?['getAdaptativeExercises'] as List?;
      if (exercisesData == null) return [];
      
      return exercisesData.map((exerciseJson) => Exercise.fromJson(exerciseJson)).toList();
    } catch (e) {
      throw Exception('Error al obtener ejercicios adaptativos: $e');
    }
  }

  /// Verifica si el estudiante debe recibir ejercicios adaptativos
  /// (cada 5 lecciones completadas)
  static bool shouldUnlockAdaptiveExercises(int completedLessons) {
    return completedLessons > 0 && completedLessons % 5 == 0;
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