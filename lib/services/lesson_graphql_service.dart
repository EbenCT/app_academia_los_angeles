// lib/services/lesson_graphql_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/lesson_models.dart';
import '../graphql/lesson_queries.dart';
import 'graphql_service.dart';

/// Servicio GraphQL para el manejo de lecciones
/// Reemplaza LessonApiService manteniendo la misma interfaz
class LessonGraphQLService {
  late final GraphQLClient _client;
  
  LessonGraphQLService._();
  
  static LessonGraphQLService? _instance;
  static Future<LessonGraphQLService> getInstance() async {
    if (_instance == null) {
      _instance = LessonGraphQLService._();
      _instance!._client = await GraphQLService.getClient();
    }
    return _instance!;
  }

  /// Obtener temas de una materia específica
  Future<List<Topic>> getTopicsBySubject(int subjectId) async {
    try {
      print('🔍 Obteniendo temas para materia $subjectId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getTopicsBySubject),
        variables: {'subjectId': subjectId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final List<dynamic>? topicsData = result.data?['topicsBySubject'];
      if (topicsData == null) {
        print('⚠️ No se encontraron temas para la materia $subjectId');
        return [];
      }

      final topics = topicsData.map((json) => Topic.fromJson(json)).toList();
      print('✅ ${topics.length} temas obtenidos para materia $subjectId');
      
      return topics;
    } catch (e) {
      print('💥 Error obteniendo temas: $e');
      throw Exception('Error al cargar temas: $e');
    }
  }

  /// Obtener lecciones de un tema específico
  Future<List<Lesson>> getLessonsByTopic(int topicId) async {
    try {
      print('🔍 Obteniendo lecciones para tema $topicId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getLessonsByTopic),
        variables: {'topicId': topicId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final List<dynamic>? lessonsData = result.data?['lessonsByTopic'];
      if (lessonsData == null) {
        print('⚠️ No se encontraron lecciones para el tema $topicId');
        return [];
      }

      final lessons = lessonsData.map((json) => Lesson.fromJson(json)).toList();
      print('✅ ${lessons.length} lecciones obtenidas para tema $topicId');
      
      return lessons;
    } catch (e) {
      print('💥 Error obteniendo lecciones: $e');
      throw Exception('Error al cargar lecciones: $e');
    }
  }

  /// Obtener una lección específica con todos sus ejercicios
  Future<Lesson> getLessonWithExercises(int lessonId) async {
    try {
      print('🔍 Obteniendo lección completa $lessonId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getLessonWithExercises),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final Map<String, dynamic>? lessonData = result.data?['lesson'];
      if (lessonData == null) {
        throw Exception('Lección $lessonId no encontrada');
      }

      final lesson = Lesson.fromJson(lessonData);
      print('✅ Lección $lessonId obtenida con ${lesson.exercises.length} ejercicios');
      
      return lesson;
    } catch (e) {
      print('💥 Error obteniendo lección: $e');
      throw Exception('Error al cargar lección: $e');
    }
  }

  /// Obtener progreso del estudiante para un tema
  Future<List<LessonProgress>> getLessonProgress(int studentId, int topicId) async {
    try {
      print('🔍 Obteniendo progreso estudiante $studentId tema $topicId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getLessonProgress),
        variables: {
          'studentId': studentId,
          'topicId': topicId,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final List<dynamic>? progressData = result.data?['lessonProgress'];
      if (progressData == null) {
        print('⚠️ No se encontró progreso para estudiante $studentId tema $topicId');
        return [];
      }

      final progress = progressData.map((json) => LessonProgress.fromJson(json)).toList();
      print('✅ Progreso obtenido: ${progress.length} lecciones');
      
      return progress;
    } catch (e) {
      print('💥 Error obteniendo progreso: $e');
      throw Exception('Error al cargar progreso: $e');
    }
  }

  /// Guardar progreso de ejercicio
  Future<void> saveExerciseProgress(StudentExerciseProgress progress) async {
    try {
      print('💾 Guardando progreso ejercicio ${progress.exerciseId}');
      
      // Calcular tiempo transcurrido
      final timeSpent = progress.finishedAt != null && progress.startedAt != null 
          ? progress.finishedAt!.difference(progress.startedAt!).inSeconds 
          : 30; // Default 30 segundos

      final MutationOptions options = MutationOptions(
        document: gql(LessonQueries.saveExerciseProgress),
        variables: {
          'input': {
            'studentId': progress.studentId,
            'exerciseId': progress.exerciseId,
            'isCorrect': !progress.error, // error = false significa correcto
            'timeSpent': timeSpent,
            'selectedOptionId': null, // No disponible en tu modelo actual
            'attempts': 1, // Default 1 intento
          },
        },
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('❌ Error GraphQL guardando progreso: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      print('✅ Progreso guardado exitosamente');
    } catch (e) {
      print('💥 Error guardando progreso: $e');
      throw Exception('Error guardando progreso: $e');
    }
  }

  /// Actualizar progreso de lección
  Future<void> updateLessonProgress({
    required int studentId,
    required int lessonId,
    bool? isCompleted,
    bool? isUnlocked,
    int? attempts,
    double? bestScore,
    int? timeSpent,
  }) async {
    try {
      print('💾 Actualizando progreso lección $lessonId');
      
      final MutationOptions options = MutationOptions(
        document: gql(LessonQueries.updateLessonProgress),
        variables: {
          'input': {
            'studentId': studentId,
            'lessonId': lessonId,
            if (isCompleted != null) 'isCompleted': isCompleted,
            if (isUnlocked != null) 'isUnlocked': isUnlocked,
            if (attempts != null) 'attempts': attempts,
            if (bestScore != null) 'bestScore': bestScore,
            if (timeSpent != null) 'timeSpent': timeSpent,
          },
        },
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('❌ Error GraphQL actualizando progreso: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      print('✅ Progreso de lección actualizado exitosamente');
    } catch (e) {
      print('💥 Error actualizando progreso de lección: $e');
      throw Exception('Error actualizando progreso: $e');
    }
  }

  /// Obtener estadísticas del estudiante en una materia
  Future<Map<String, dynamic>> getSubjectStats(int studentId, int subjectId) async {
    try {
      print('📊 Obteniendo estadísticas estudiante $studentId materia $subjectId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getSubjectStats),
        variables: {
          'studentId': studentId,
          'subjectId': subjectId,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final Map<String, dynamic>? statsData = result.data?['subjectStats'];
      if (statsData == null) {
        print('⚠️ No se encontraron estadísticas para estudiante $studentId materia $subjectId');
        return {};
      }

      print('✅ Estadísticas obtenidas');
      return statsData;
    } catch (e) {
      print('💥 Error obteniendo estadísticas: $e');
      throw Exception('Error al cargar estadísticas: $e');
    }
  }

  /// Obtener lecciones recomendadas para el estudiante
  Future<List<Lesson>> getRecommendedLessons(int studentId, {int limit = 5}) async {
    try {
      print('🎯 Obteniendo lecciones recomendadas para estudiante $studentId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonQueries.getRecommendedLessons),
        variables: {
          'studentId': studentId,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        throw _handleGraphQLException(result.exception!);
      }

      final List<dynamic>? lessonsData = result.data?['recommendedLessons'];
      if (lessonsData == null) {
        print('⚠️ No se encontraron lecciones recomendadas');
        return [];
      }

      final lessons = lessonsData.map((json) => Lesson.fromJson(json)).toList();
      print('✅ ${lessons.length} lecciones recomendadas obtenidas');
      
      return lessons;
    } catch (e) {
      print('💥 Error obteniendo lecciones recomendadas: $e');
      throw Exception('Error al cargar recomendaciones: $e');
    }
  }

  /// Revalidar cache y obtener datos frescos
  Future<void> invalidateCache() async {
    try {
      _client.cache.store.reset();
      print('🔄 Cache invalidado');
    } catch (e) {
      print('⚠️ Error invalidando cache: $e');
    }
  }

  /// Manejar excepciones de GraphQL
  Exception _handleGraphQLException(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      print('🚨 GraphQL Error: ${error.message}');
      
      // Manejar errores específicos
      switch (error.extensions?['code']) {
        case 'UNAUTHENTICATED':
          return Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
        case 'FORBIDDEN':
          return Exception('No tienes permisos para acceder a este contenido.');
        case 'NOT_FOUND':
          return Exception('El contenido solicitado no fue encontrado.');
        case 'BAD_USER_INPUT':
          return Exception('Datos inválidos. Verifica la información e intenta de nuevo.');
        default:
          return Exception(error.message);
      }
    }
    
    if (exception.linkException != null) {
      print('🌐 Network Error: ${exception.linkException}');
      return Exception('Error de conexión. Verifica tu conexión a internet.');
    }
    
    return Exception('Error desconocido: ${exception.toString()}');
  }
}

/// Extensión para backward compatibility con la interfaz actual
class LessonApiService {
  static LessonGraphQLService? _graphqlService;

  /// Obtener temas de una materia específica
  static Future<List<Topic>> getTopicsBySubject(int subjectId) async {
    _graphqlService ??= await LessonGraphQLService.getInstance();
    return _graphqlService!.getTopicsBySubject(subjectId);
  }

  /// Obtener lecciones de un tema específico
  static Future<List<Lesson>> getLessonsByTopic(int topicId) async {
    _graphqlService ??= await LessonGraphQLService.getInstance();
    return _graphqlService!.getLessonsByTopic(topicId);
  }

  /// Obtener una lección específica con todos sus ejercicios
  static Future<Lesson> getLessonWithExercises(int lessonId) async {
    _graphqlService ??= await LessonGraphQLService.getInstance();
    return _graphqlService!.getLessonWithExercises(lessonId);
  }

  /// Obtener progreso del estudiante para un tema
  static Future<List<LessonProgress>> getLessonProgress(int studentId, int topicId) async {
    _graphqlService ??= await LessonGraphQLService.getInstance();
    return _graphqlService!.getLessonProgress(studentId, topicId);
  }

  /// Guardar progreso de ejercicio
  static Future<void> saveExerciseProgress(StudentExerciseProgress progress) async {
    _graphqlService ??= await LessonGraphQLService.getInstance();
    return _graphqlService!.saveExerciseProgress(progress);
  }
}