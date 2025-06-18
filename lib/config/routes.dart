// lib/config/routes.dart
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
import '../screens/game/integer_rescue_game.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/shop/inventory_screen.dart';

/// Contiene todas las rutas de navegación de la aplicación
class AppRoutes {
  // Nombres de rutas estáticas para fácil referencia
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main'; // Nueva ruta principal para estudiantes
  static const String mainTeacher = '/main-teacher'; // Nueva ruta principal para profesores
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
    main: (context) => const MainScreen(), // Pantalla principal para estudiantes
    mainTeacher: (context) => const MainTeacherScreen(), // Pantalla principal para profesores
    joinClassroom: (context) => const JoinClassroomScreen(),
    subjectLessons: (context) {
      final subject = ModalRoute.of(context)!.settings.arguments;
      return SubjectLessonsScreen(subject: subject);
    },
        // NUEVAS RUTAS GENÉRICAS
    topicLessons: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return GenericTopicLessonsScreen(
        topic: args['topic'],
        subject: args['subject'],
      );
    },
        genericLesson: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return GenericLessonScreen(
        lessonId: args['lessonId'],
        lessonTitle: args['lessonTitle'],
        onLessonCompleted: args['onLessonCompleted'],
      );
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
}