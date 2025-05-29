// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/coin_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/pet/floating_pet_widget.dart';
import '../../config/routes.dart';
import '../home/home_content.dart';
import '../courses/courses_content.dart';
import '../shop/shop_screen.dart';
import '../achievements/achievements_content.dart';
import '../profile/profile_content.dart';
import '../../widgets/navigation/main_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Cargar datos del estudiante
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.refreshStudentData();
    
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
    final studentProvider = Provider.of<StudentProvider>(context);

    // Si el usuario es estudiante, verificar si está en un aula
    if (user != null && user.role == 'student') {
      if (_isLoading || studentProvider.isLoading) {
        return _buildLoadingScreen('Cargando tu mundo de aventuras...');
      }

      // Si el estudiante no tiene aula, redirigir a la pantalla de unirse
      if (!studentProvider.hasClassroom) {
        Future.microtask(() {
          AppRoutes.navigateReplacementTo(context, AppRoutes.joinClassroom);
        });
        return _buildLoadingScreen('Preparando tu nave espacial...');
      }
    }

    if (_isLoading || user == null) {
      return _buildLoadingScreen('Cargando tu mundo de aventuras...');
    }

    return ChangeNotifierProvider(
      create: (_) => CoinProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            // Contenido principal con IndexedStack
            IndexedStack(
              index: _currentIndex,
              children: [
                HomeContent(),
                CoursesContent(),
                ShopScreen(),
                AchievementsContent(),
                ProfileContent(),
              ],
            ),
            
            // Widget flotante de mascota
            _buildFloatingPet(),
          ],
        ),
        bottomNavigationBar: MainBottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          userRole: user.role,
        ),
      ),
    );
  }

  Widget _buildFloatingPet() {
    return Consumer<CoinProvider>(
      builder: (context, coinProvider, child) {
        final equippedPet = coinProvider.equippedPet;
        
        if (equippedPet != null) {
          return FloatingPetWidget(
            pet: equippedPet,
            onTap: () {
              // Mostrar información de la mascota
              showDialog(
                context: context,
                builder: (context) => PetInfoDialog(pet: equippedPet),
              );
            },
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      body: LoadingIndicator(
        message: message,
        useAstronaut: true,
        size: 150,
      ),
    );
  }
}