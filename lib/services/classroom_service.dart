// lib/services/classroom_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/classroom_model.dart';
import '../models/course_model.dart';

class ClassroomService {
  final GraphQLClient _client;

  ClassroomService(this._client);

  // Query para obtener aulas del profesor
  final String _getTeacherClassroomsQuery = r'''
  query GetTeacher {
    teacher {
      id
      cellphone
      classrooms {
        id
        code
        name
        description
        createdAt
        course {
          id
          title
        }
        students {
          id
        }
      }
    }
  }
  ''';

  // Query para obtener cursos disponibles
  final String _getCoursesQuery = r'''
  query GetCourses {
    courses {
      id
      title
      description
    }
  }
  ''';

  // Mutation para crear un aula
  final String _createClassroomMutation = r'''
  mutation CreateClassroom($name: String!, $description: String, $courseId: Int!) {
    createClassroom(createClassroomInput: {
      name: $name,
      description: $description,
      courseId: $courseId
    }) {
      id
      code
      name
      description
      createdAt
      teacher {
        id
      }
      course {
        id
        title
      }
      students {
        id
      }
    }
  }
  ''';

  // Obtener las aulas del profesor
Future<List<ClassroomModel>> getTeacherClassrooms() async {
  try {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getTeacherClassroomsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print('GraphQL Error: ${result.exception}');
      throw Exception(_getErrorMessage(result.exception));
    }

    // La estructura de la respuesta es correcta, pero asegurémonos de manejarla adecuadamente
    final teacher = result.data?['teacher'];
    if (teacher == null) {
      print('Teacher data is null in response');
      return [];
    }

    // Verificar si classrooms existe
    final classrooms = teacher['classrooms'] as List<dynamic>?;
    if (classrooms == null || classrooms.isEmpty) {
      print('No classrooms found for teacher');
      return [];
    }

    // Convertir cada aula en un modelo
    return classrooms.map((classroom) {
      try {
        return ClassroomModel.fromJson(classroom);
      } catch (e) {
        print('Error parsing classroom: $e');
        print('Classroom data: $classroom');
        // En caso de error, saltamos este elemento
        throw e;
      }
    }).toList();
  } catch (e) {
    print('Error getting teacher classrooms: $e');
    throw e;
  }
}

  // Obtener los cursos disponibles
  Future<List<CourseModel>> getCourses() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getCoursesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception}');
        throw Exception(_getErrorMessage(result.exception));
      }

      final courses = result.data?['courses'] as List<dynamic>;
      return courses.map((course) => CourseModel.fromJson(course)).toList();
    } catch (e) {
      print('Error getting courses: $e');
      throw e;
    }
  }

  // Crear una nueva aula
  Future<ClassroomModel> createClassroom(String name, String? description, int courseId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_createClassroomMutation),
          variables: {
            'name': name,
            'description': description,
            'courseId': courseId,
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception}');
        throw Exception(_getErrorMessage(result.exception));
      }

      final classroom = result.data?['createClassroom'];
      if (classroom != null) {
        return ClassroomModel.fromJson(classroom);
      }
      
      throw Exception('No se pudo crear el aula');
    } catch (e) {
      print('Error creating classroom: $e');
      throw e;
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