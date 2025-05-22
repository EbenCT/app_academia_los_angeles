// lib/widgets/navigation/main_bottom_navigation.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget para la navegación inferior principal
class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;
  
  const MainBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
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
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 11,
          ),
          items: isTeacher ? _buildTeacherItems() : _buildStudentItems(),
          onTap: onTap,
          elevation: 0,
        ),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildTeacherItems() => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      activeIcon: Icon(Icons.dashboard_rounded),
      label: 'Mis Aulas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school_rounded),
      activeIcon: Icon(Icons.school_rounded),
      label: 'Estudiantes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment_rounded),
      activeIcon: Icon(Icons.assignment_rounded),
      label: 'Evaluaciones',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Perfil',
    ),
  ];
  
  List<BottomNavigationBarItem> _buildStudentItems() => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_stories_rounded),
      activeIcon: Icon(Icons.auto_stories_rounded),
      label: 'Materias',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events_rounded),
      activeIcon: Icon(Icons.emoji_events_rounded),
      label: 'Logros',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Perfil',
    ),
  ];
}