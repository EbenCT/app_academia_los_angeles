// lib/services/topic_lesson_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';

class TopicLessonService {
  final GraphQLClient _client;

  TopicLessonService(this._client);

  // Query para obtener topics de una materia con sus lecciones y ejercicios
  final String _getSubjectTopicsQuery = r'''
  query GetSubject($searchParam: String!) {
    subject(searchParam: $searchParam) {
      id
      code
      name
      description
      topics {
        id
        name
        description
        xpReward
        lessons {
          id
          title
          content
          img_link
          exercises {
            id
            severity
            question
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
      }
    }
  }
  ''';

  // Query para obtener una lección específica con sus ejercicios
  final String _getLessonQuery = r'''
  query GetLesson($id: Int!) {
    lesson(id: $id) {
      id
      title
      content
      img_link
      exercises {
        id
        severity
        question
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
  }
  ''';

  // Mutation para enviar resultado de ejercicio
  final String _studentDoExerciseMutation = r'''
  mutation StudentDoExercise($studentDoExerciseInput: StudentDoExerciseInput!) {
    studentDoExercise(studentDoExerciseInput: $studentDoExerciseInput) {
      id
      started_at
      finished_at
      errors
    }
  }
  ''';

  // Obtener topics con lecciones de una materia
  Future<Map<String, dynamic>> getSubjectTopics(String subjectId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getSubjectTopicsQuery),
          variables: {
            'searchParam': subjectId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      
      final subjectData = result.data?['subject'] ?? {};
      
      // Filtrar ejercicios en las lecciones según las reglas:
      // - Primera lección: solo ejercicios fáciles
      // - Demás lecciones: solo ejercicios de nivel medio
      if (subjectData['topics'] != null) {
        final topics = subjectData['topics'] as List;
        
        for (var topic in topics) {
          if (topic['lessons'] != null) {
            final lessons = topic['lessons'] as List;
            
            for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
              final lesson = lessons[lessonIndex];
              
              if (lesson['exercises'] != null) {
                final exercises = lesson['exercises'] as List;
                
                // Filtrar ejercicios según la posición de la lección
                final filteredExercises = exercises.where((exercise) {
                  final severity = (exercise['severity'] as String).toLowerCase();
                  
                  if (lessonIndex == 0) {
                    // Primera lección: solo ejercicios fáciles
                    return severity == 'easy';
                  } else {
                    // Demás lecciones: solo ejercicios de nivel medio
                    return severity == 'medium';
                  }
                }).toList();
                
                // Reemplazar los ejercicios con los filtrados
                lesson['exercises'] = filteredExercises;
                
                print('Lección ${lessonIndex + 1}: ${filteredExercises.length} ejercicios filtrados (${lessonIndex == 0 ? 'easy' : 'medium'})');
              }
            }
          }
        }
      }
      
      return subjectData;
    } catch (e) {
      throw Exception('Error al obtener topics de la materia: $e');
    }
  }

  // Obtener una lección específica
  Future<Map<String, dynamic>> getLesson(int lessonId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getLessonQuery),
          variables: {
            'id': lessonId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      
      return result.data?['lesson'] ?? {};
    } catch (e) {
      throw Exception('Error al obtener la lección: $e');
    }
  }

  // Enviar resultado de ejercicio al backend
  Future<Map<String, dynamic>> submitExerciseResult({
    required int exerciseId,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int errors,
  }) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_studentDoExerciseMutation),
          variables: {
            'studentDoExerciseInput': {
              'exercise_id': exerciseId,
              'started_at': startedAt.toIso8601String(),
              'finished_at': finishedAt.toIso8601String(),
              'errors': errors,
            },
          },
        ),
      );
      
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      
      return result.data?['studentDoExercise'] ?? {};
    } catch (e) {
      throw Exception('Error al enviar resultado del ejercicio: $e');
    }
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