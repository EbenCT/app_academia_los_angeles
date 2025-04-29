// lib/services/student_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';

class StudentService {
  final GraphQLClient _client;

  StudentService(this._client);

  // Mutation para unirse a un aula
  final String _joinClassroomMutation = r'''
  mutation UpdateStudent($classroomId: Int!) {
    updateStudent(updateStudentInput: {
      classroomId: $classroomId
    }) {
      id
      level
      xp
      classroom {
        id
        name
        code
        course {
          id
          title
        }
      }
      user {
        id
        firstName
        lastName
        email
      }
    }
  }
  ''';

  // Obtener información del estudiante (ampliada)
  final String _getStudentQuery = r'''
  query GetStudent {
    student {
      id
      level
      xp
      classroom {
        id
        name
        code
        course {
          id
          title
        }
      }
      user {
        id
        firstName
        lastName
        email
      }
    }
  }
  ''';

  // Obtener detalles de un curso
  final String _getCourseQuery = r'''
  query GetCourse($id: Int!) {
    course(id: $id) {
      id
      title
      description
      subjects {
        id
        code
        name
        description
      }
    }
  }
  ''';

  // Método para obtener la información del estudiante
  Future<Map<String, dynamic>> getStudentInfo() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getStudentQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      return result.data?['student'] ?? {};
    } catch (e) {
      throw Exception('Error al obtener información del estudiante: $e');
    }
  }

  // Método para obtener detalles de un curso
  Future<Map<String, dynamic>?> getCourseDetails(int courseId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getCourseQuery),
          variables: {
            'id': courseId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      return result.data?['course'];
    } catch (e) {
      throw Exception('Error al obtener detalles del curso: $e');
    }
  }

  // Método para unirse a un aula por código
  Future<Map<String, dynamic>> joinClassroom(int classroomId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_joinClassroomMutation),
          variables: {
            'classroomId': classroomId,
          },
        ),
      );
      if (result.hasException) {
        throw Exception(_getErrorMessage(result.exception));
      }
      return result.data?['updateStudent'] ?? {};
    } catch (e) {
      throw Exception('Error al unirse al aula: $e');
    }
  }

  // Validar el código del aula y obtener su ID
  Future<int?> validateClassroomCode(String code) async {
    try {
      // Intentar convertir el código a un número entero
      final classroomId = int.tryParse(code);
      if (classroomId != null && classroomId > 0) {
        // Si es un número válido, lo devolvemos directamente
        return classroomId;
      }
      // Si no es un número válido, retornamos null
      return null;
    } catch (e) {
      print('Error al validar código: $e');
      return null;
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