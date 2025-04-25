// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../constants/api_constanst.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GraphQLClient _client;

  // Constructor que recibe el cliente GraphQL
  AuthService(this._client);

  // Mutación para iniciar sesión
  final String _signInMutation = r'''
  mutation SignIn($email: String!, $password: String!) {
    signIn(signInInput: {email: $email, password: $password}) {
      token
      user {
        id
        firstName
        lastName
        email
        role
        isActive
      }
    }
  }
  ''';

  // Mutación para validar el token
  final String _revalidateTokenQuery = r'''
  query RevalidateToken {
    revalidateToken {
      token
      user {
        id
        firstName
        lastName
        email
        role
        isActive
      }
    }
  }
  ''';
  final String _signUpMutation = r'''
mutation SignUp($email: String!, $password: String!, $firstName: String!, $lastName: String!, $role: Role!) {
  signUp(signUpInput: {
    email: $email
    password: $password
    firstName: $firstName
    lastName: $lastName
    role: $role
  }) {
    token
    user {
      id
      firstName
      lastName
      email
      role
      isActive
    }
  }
}
''';

// Modificación en lib/services/auth_service.dart
// Agregar estas mutaciones a la clase AuthService

final String _signUpStudentMutation = r'''
mutation SignUpStudent($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
  signUpStudent(signUpStudentInput: {
    email: $email
    password: $password
    firstName: $firstName
    lastName: $lastName
  }) {
    token
    user {
      id
      firstName
      lastName
      email
      role
      isActive
    }
  }
}
''';

final String _signUpTeacherMutation = r'''
mutation SignUpTeacher($email: String!, $password: String!, $firstName: String!, $lastName: String!, $cellphone: Int!) {
  signUpTeacher(signUpTeacherInput: {
    email: $email
    password: $password
    firstName: $firstName
    lastName: $lastName
    cellphone: $cellphone
  }) {
    token
    user {
      id
      firstName
      lastName
      email
      role
      isActive
    }
  }
}
''';

// Agregar estos métodos a la clase AuthService

Future<Map<String, dynamic>> registerStudent(
  String email,
  String password,
  String firstName,
  String lastName,
) async {
  try {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_signUpStudentMutation),
        variables: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      ),
    );
    
    if (result.hasException) {
      print('GraphQL Error: ${result.exception.toString()}');
      return {
        'success': false,
        'message': 'Error de registro: ${_getErrorMessage(result.exception)}',
      };
    }
    
    final data = result.data?['signUpStudent'];
    if (data != null) {
      // Guardar token
      await _secureStorage.write(key: 'token', value: data['token']);
      // Transformar los datos del usuario para que coincidan con el modelo UserModel
      final user = {
        'id': data['user']['id'],
        'username': '${data['user']['firstName']} ${data['user']['lastName']}',
        'email': data['user']['email'],
        'role': data['user']['role'].toString().toLowerCase(),
        'achievements': [],
        'points': 0,
        'level': 1,
      };
      
      return {
        'success': true,
        'token': data['token'],
        'user': user,
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo completar el registro de estudiante',
      };
    }
  } catch (e) {
    print('Exception during student registration: $e');
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}

Future<Map<String, dynamic>> registerTeacher(
  String email,
  String password,
  String firstName,
  String lastName,
  int cellphone,
) async {
  try {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_signUpTeacherMutation),
        variables: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'cellphone': cellphone,
        },
      ),
    );
    
    if (result.hasException) {
      print('GraphQL Error: ${result.exception.toString()}');
      return {
        'success': false,
        'message': 'Error de registro: ${_getErrorMessage(result.exception)}',
      };
    }
    
    final data = result.data?['signUpTeacher'];
    if (data != null) {
      // Guardar token
      await _secureStorage.write(key: 'token', value: data['token']);
      // Transformar los datos del usuario para que coincidan con el modelo UserModel
      final user = {
        'id': data['user']['id'],
        'username': '${data['user']['firstName']} ${data['user']['lastName']}',
        'email': data['user']['email'],
        'role': data['user']['role'].toString().toLowerCase(),
        'achievements': [],
        'points': 0,
        'level': 1,
      };
      
      return {
        'success': true,
        'token': data['token'],
        'user': user,
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo completar el registro de profesor',
      };
    }
  } catch (e) {
    print('Exception during teacher registration: $e');
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}

  /// Intenta iniciar sesión con las credenciales proporcionadas
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_signInMutation),
          variables: {
            'email': email,
            'password': password,
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        return {
          'success': false,
          'message': 'Error de autenticación: ${_getErrorMessage(result.exception)}',
        };
      }

      final data = result.data?['signIn'];
      if (data != null) {
        // Guardar token
        await _secureStorage.write(key: 'token', value: data['token']);
        
        // Transformar los datos del usuario para que coincidan con el modelo UserModel
        final user = {
          'id': data['user']['id'],
          'username': '${data['user']['firstName']} ${data['user']['lastName']}', // Combinamos nombre y apellido
          'email': data['user']['email'],
          'role': data['user']['role'].toString().toLowerCase(), // Convertir a minúsculas para coincidir
          'achievements': [], // Valores predeterminados
          'points': 0,
          'level': 1,
        };

        return {
          'success': true,
          'token': data['token'],
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': 'No se pudo obtener información de usuario',
        };
      }
    } catch (e) {
      print('Exception during login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Obtiene la información del usuario usando el token guardado
  Future<Map<String, dynamic>> getUserData(String token) async {
    try {
      // Actualizar las cabeceras del cliente con el token
      final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer $token',
      );
      
      final Link link = authLink.concat(
        HttpLink('${ApiConstants.baseUrl}/graphql')
      );
      
      final client = GraphQLClient(
        cache: GraphQLCache(store: InMemoryStore()),
        link: link,
      );

      final result = await client.query(
        QueryOptions(
          document: gql(_revalidateTokenQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Error validando token: ${_getErrorMessage(result.exception)}');
      }

      final data = result.data?['revalidateToken'];
      if (data != null) {
        // Guardar nuevo token si es diferente
        final newToken = data['token'];
        if (newToken != token) {
          await _secureStorage.write(key: 'token', value: newToken);
        }

        // Transformar los datos del usuario
        final user = {
          'id': data['user']['id'],
          'username': '${data['user']['firstName']} ${data['user']['lastName']}',
          'email': data['user']['email'],
          'role': data['user']['role'].toString().toLowerCase(),
          'achievements': [],
          'points': 0,
          'level': 1,
        };

        return user;
      } else {
        throw Exception('No se pudo obtener información de usuario');
      }
    } catch (e) {
      print('Error getting user data: $e');
      throw e;
    }
  }

  /// Cierra la sesión eliminando el token
  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
  }

  /// Extrae un mensaje de error más amigable
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

Future<Map<String, dynamic>> register(
  String email,
  String password,
  String firstName,
  String lastName,
  String role,
) async {
  try {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_signUpMutation),
        variables: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        },
      ),
    );

    if (result.hasException) {
      print('GraphQL Error: ${result.exception.toString()}');
      return {
        'success': false,
        'message': 'Error de registro: ${_getErrorMessage(result.exception)}',
      };
    }

    final data = result.data?['signUp'];
    if (data != null) {
      // Guardar token
      await _secureStorage.write(key: 'token', value: data['token']);
      
      // Transformar los datos del usuario para que coincidan con el modelo UserModel
      final user = {
        'id': data['user']['id'],
        'username': '${data['user']['firstName']} ${data['user']['lastName']}',
        'email': data['user']['email'],
        'role': data['user']['role'].toString().toLowerCase(),
        'achievements': [],
        'points': 0,
        'level': 1,
      };
      
      return {
        'success': true,
        'token': data['token'],
        'user': user,
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo completar el registro',
      };
    }
  } catch (e) {
    print('Exception during registration: $e');
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}
}
