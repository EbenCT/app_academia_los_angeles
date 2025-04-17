// lib/services/graphql_service.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constanst.dart';

class GraphQLService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static final HttpLink _httpLink = HttpLink('${ApiConstants.baseUrl}/graphql');
  
  /// Inicializa el cliente GraphQL con o sin token
  static GraphQLClient initClient({String? token}) {
    final AuthLink authLink = AuthLink(
      getToken: () => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(_httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
  
  /// Obtiene el cliente GraphQL con el token almacenado (si existe)
  static Future<GraphQLClient> getClient() async {
    final token = await _secureStorage.read(key: 'token');
    return initClient(token: token);
  }
  
  /// Crea un ValueNotifier para el cliente GraphQL (útil para envolver la app)
  static Future<ValueNotifier<GraphQLClient>> getClientNotifier() async {
    final client = await getClient();
    return ValueNotifier<GraphQLClient>(client);
  }
  
  /// Actualiza el token en el cliente GraphQL
  static Future<GraphQLClient> updateClientWithToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
    return initClient(token: token);
  }
}