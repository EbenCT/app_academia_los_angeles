// lib/config/routes_fixed.dart
// CORREGIDO: Manejo correcto de tipos para Subject

import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../screens/game/integer_lesson_screen_interactive.dart';
import '../screens/main/main_screen.dart';
import '../screens/main/main_teacher_screen.dart';
import '../screens/auth/register_teacher_screen.dart';
import '../screens/join_classroom_screen.dart';
import '../screens/courses/subject_lessons_screen.dart';
import '../screens/game/integer_rescue_game.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/shop/inventory_screen.dart';
import '../screens/courses/generic_topic_lessons_screen.dart';
import '../screens/game/generic_lesson_screen.dart';
import '../models/lesson_models.dart'; // Importar modelos

/// Contiene todas las rutas de navegación de la aplicación
class AppRoutes {
  // Nombres de rutas estáticas para fácil referencia
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String mainTeacher = '/main-teacher';
  static const String profile = '/profile';
  static const String subjectLessons = '/subject-lessons';
  static const String topicLessons = '/topic-lessons';
  static const String genericLesson = '/generic-lesson';
  static const String registerTeacher = '/registerTeacher';
  static const String joinClassroom = '/joinClassroom';
  static const String integerRescueGame = '/games/integer-rescue';
  static const String integerLesson = '/integer_lesson';
  static const String shop = '/shop';
  static const String inventory = '/inventory';

  /// Mapa de rutas nombradas para la navegación en MaterialApp
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    registerTeacher: (context) => const RegisterTeacherScreen(),
    main: (context) => const MainScreen(),
    mainTeacher: (context) => const MainTeacherScreen(),
    joinClassroom: (context) => const JoinClassroomScreen(),
    
    // CORREGIDO: Manejo seguro de tipos para SubjectLessonsScreen
    subjectLessons: (context) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      
      // Verificar que el argumento sea del tipo correcto
      if (arguments is Subject) {
        return SubjectLessonsScreen(subject: arguments);
      } else if (arguments is Map<String, dynamic>) {
        // Si viene como Map, convertir a Subject
        final subject = Subject.fromJson(arguments);
        return SubjectLessonsScreen(subject: subject);
      } else {
        // Fallback: crear subject básico para evitar crash
        final subject = Subject(
          id: 1,
          code: 'UNKNOWN',
          name: 'Materia no encontrada',
          description: 'Error al cargar materia',
        );
        return SubjectLessonsScreen(subject: subject);
      }
    },
    
    // RUTAS GENÉRICAS
    topicLessons: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      
      if (args != null && args.containsKey('topic') && args.containsKey('subject')) {
        // Si los argumentos vienen como objetos Topic y Subject
        final topic = args['topic'] is Topic 
            ? args['topic'] as Topic
            : Topic.fromJson(args['topic'] as Map<String, dynamic>);
            
        final subject = args['subject'] is Subject 
            ? args['subject'] as Subject
            : Subject.fromJson(args['subject'] as Map<String, dynamic>);
            
        return GenericTopicLessonsScreen(
          topic: topic,
          subject: subject,
        );
      } else {
        // Fallback: regresar a pantalla anterior
        Navigator.of(context).pop();
        return const SizedBox(); // Widget vacío que nunca se mostrará
      }
    },
    
    genericLesson: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        return GenericLessonScreen(
          lessonId: args['lessonId'] ?? 1,
          lessonTitle: args['lessonTitle'] ?? 'Lección',
          onLessonCompleted: args['onLessonCompleted'],
        );
      } else {
        // Fallback
        Navigator.of(context).pop();
        return const SizedBox();
      }
    },
    
    integerRescueGame: (context) => const IntegerRescueGame(),
    integerLesson: (context) => const IntegerLessonScreenInteractive(),
    shop: (context) => const ShopScreen(),
    inventory: (context) => const InventoryScreen(),
  };

  // Métodos de navegación auxiliares
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateReplacementTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Navega al inicio y limpia todo el stack de navegación
  static void navigateToMainAndClearStack(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      main,
      (Route<dynamic> route) => false,
    );
  }

  static void navigateToTeacherMainAndClearStack(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      mainTeacher,
      (Route<dynamic> route) => false,
    );
  }

  /// NUEVOS MÉTODOS: Navegación segura con tipos específicos
  
  /// Navegar a lecciones de materia con tipo seguro
  static void navigateToSubjectLessons(BuildContext context, Subject subject) {
    Navigator.pushNamed(
      context,
      subjectLessons,
      arguments: subject, // Pasar directamente el objeto Subject
    );
  }

  /// Navegar a lecciones de tema con tipos seguros
  static void navigateToTopicLessons(BuildContext context, Topic topic, Subject subject) {
    Navigator.pushNamed(
      context,
      topicLessons,
      arguments: {
        'topic': topic,
        'subject': subject,
      },
    );
  }

  /// Navegar a lección específica con tipos seguros
  static void navigateToGenericLesson(
    BuildContext context, 
    int lessonId, 
    String lessonTitle, 
    {VoidCallback? onLessonCompleted}
  ) {
    Navigator.pushNamed(
      context,
      genericLesson,
      arguments: {
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'onLessonCompleted': onLessonCompleted,
      },
    );
  }
}