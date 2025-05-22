// lib/screens/main/main_teacher_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../home/teacher_home_content.dart';
import '../teacher/teacher_students_content.dart';
import '../teacher/teacher_evaluations_content.dart';
import '../profile/profile_content.dart';
import '../../widgets/navigation/main_bottom_navigation.dart';

class MainTeacherScreen extends StatefulWidget {
  const MainTeacherScreen({super.key});

  @override
  State<MainTeacherScreen> createState() => _MainTeacherScreenState();
}

class _MainTeacherScreenState extends State<MainTeacherScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulamos tiempo de carga
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (_isLoading || user == null) {
      return Scaffold(
        body: LoadingIndicator(
          message: 'Preparando tu estación de comando...',
          useAstronaut: true,
          size: 150,
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TeacherHomeContent(),
          TeacherStudentsContent(),
          TeacherEvaluationsContent(),
          ProfileContent(),
        ],
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userRole: user.role,
      ),
    );
  }
}