// lib/services/student_tracking_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/student_tracking_model.dart';

class StudentTrackingService {
  final GraphQLClient _client;

  StudentTrackingService(this._client);

  // Query para obtener estudiantes de un aula específica con métricas
  final String _getClassroomStudentsQuery = r'''
  query GetClassroom($id: Int!) {
    classroom(id: $id) {
      id
      name
      students {
        id
        level
        xp
        user {
          id
          firstName
          lastName
          email
        }
      }
    }
  }
  ''';

  // Query para obtener detalles de un estudiante específico
  final String _getStudentDetailQuery = r'''
  query GetStudent($id: Int!) {
    student(id: $id) {
      id
      level
      xp
      user {
        id
        firstName
        lastName
        email
      }
      doneExercises {
        id
        errors
        timeSpent
        createdAt
        exercise {
          id
          title
          lesson {
            title
            topic {
              name
              subject {
                name
              }
            }
          }
        }
      }
    }
  }
  ''';

  // Obtener estudiantes de un aula
  Future<List<StudentTrackingModel>> getClassroomStudents(int classroomId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getClassroomStudentsQuery),
          variables: {'id': classroomId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }

      final classroom = result.data?['classroom'];
      if (classroom == null || classroom['students'] == null) {
        return [];
      }

      final studentsData = classroom['students'] as List<dynamic>;
      return studentsData
          .map((studentJson) => StudentTrackingModel.fromJson(studentJson))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes: $e');
    }
  }

  // Obtener detalles específicos de un estudiante
  Future<StudentTrackingModel?> getStudentDetails(int studentId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getStudentDetailQuery),
          variables: {'id': studentId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }

      final studentData = result.data?['student'];
      if (studentData == null) {
        return null;
      }

      return StudentTrackingModel.fromJson(studentData);
    } catch (e) {
      throw Exception('Error al obtener detalles del estudiante: $e');
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