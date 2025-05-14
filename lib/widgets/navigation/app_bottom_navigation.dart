import 'package:flutter/material.dart';
import '../../config/routes.dart';
import '../../theme/app_colors.dart';

/// Widget reutilizable para las barras de navegación
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String userRole;
  
  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isTeacher = userRole == 'teacher';
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode
              ? AppColors.darkSurface
              : Colors.white,
          selectedItemColor: isTeacher ? AppColors.secondary : AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Comic Sans MS',
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Comic Sans MS',
          ),
          items: isTeacher ? _buildTeacherItems() : _buildStudentItems(),
          onTap: (index) => _handleNavigation(context, index, isTeacher),
        ),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildTeacherItems() => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      label: 'Mis Aulas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school_rounded),
      label: 'Estudiantes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment_rounded),
      label: 'Evaluaciones',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      label: 'Perfil',
    ),
  ];
  
  List<BottomNavigationBarItem> _buildStudentItems() => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_stories_rounded),
      label: 'Cursos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events_rounded),
      label: 'Logros',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      label: 'Perfil',
    ),
  ];
  
  void _handleNavigation(BuildContext context, int index, bool isTeacher) {
    // Si ya estamos en la pantalla, no hacer nada
    if (index == currentIndex) return;
    
    if (isTeacher) {
      _handleTeacherNavigation(context, index);
    } else {
      _handleStudentNavigation(context, index);
    }
  }
  
  void _handleTeacherNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        AppRoutes.navigateReplacementTo(context, AppRoutes.teacherHome);
        break;
      case 3:
        AppRoutes.navigateTo(context, AppRoutes.profile);
        break;
      default:
        // Funciones en desarrollo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Función en desarrollo',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
  
  void _handleStudentNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        AppRoutes.navigateReplacementTo(context, AppRoutes.home);
        break;
      case 1:
        AppRoutes.navigateTo(context, AppRoutes.courses);
        break;
      case 2:
        AppRoutes.navigateTo(context, AppRoutes.achievements);
        break;
      case 3:
        AppRoutes.navigateTo(context, AppRoutes.profile);
        break;
    }
  }
}