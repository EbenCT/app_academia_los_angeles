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
      
      return result.data?['subject'] ?? {};
    } catch (e) {
      throw Exception('Error al obtener topics de la materia: $e');
    }
  }

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