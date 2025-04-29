// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/register_teacher_screen.dart';
import '../screens/home/teacher_home_screen.dart';
import '../screens/join_classroom_screen.dart';
import '../../screens/profile_screen.dart';
import '../screens/game/integer_rescue_game.dart';
import '../screens/game/integer_lesson_screen.dart'; // Importación de la lección de números enteros

/// Contiene todas las rutas de navegación de la aplicación
class AppRoutes {
  // Nombres de rutas estáticas para fácil referencia
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String courses = '/courses';

  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  static const String registerTeacher = '/registerTeacher';
  static const String teacherHome = '/teacherHome';
  static const String joinClassroom = '/joinClassroom';
  static const String integerRescueGame = '/games/integer-rescue';
  static const String integerLesson = '/lessons/integer-lesson'; // Nueva ruta para la lección

  /// Mapa de rutas nombradas para la navegación en MaterialApp
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    registerTeacher: (context) => const RegisterTeacherScreen(),
    home: (context) => const HomeScreen(),
    teacherHome: (context) => const TeacherHomeScreen(),
    joinClassroom: (context) => const JoinClassroomScreen(),
    profile: (context) => const ProfileScreen(),
    integerRescueGame: (context) => const IntegerRescueGame(),
    integerLesson: (context) => const IntegerLessonScreen(), // Añadida la nueva ruta
    /*courses: (context) => const CoursesScreen(),
    achievements: (context) => const AchievementsScreen(),
    leaderboard: (context) => const LeaderboardScreen(),*/
  };

  /// Navega a una ruta nombrada
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Navega a una ruta y reemplaza la actual en el stack
  static void navigateReplacementTo(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navega al inicio y limpia todo el stack de navegación
  static void navigateToHomeAndClearStack(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (Route<dynamic> route) => false,
    );
  }

  static void navigateToTeacherHomeAndClearStack(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      teacherHome,
      (Route<dynamic> route) => false,
    );
  }
}