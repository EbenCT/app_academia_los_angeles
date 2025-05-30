// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/coin_provider.dart';
import '../../providers/booster_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/pet/floating_pet_widget.dart';
import '../../config/routes.dart';
import '../home/home_content.dart';
import '../courses/courses_content.dart';
import '../shop/active_booster_indicator.dart';
import '../shop/shop_screen.dart';
import '../achievements/achievements_content.dart';
import '../profile/profile_content.dart';
import '../../widgets/navigation/main_bottom_navigation.dart';
import '../../theme/app_colors.dart';

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

    return Scaffold(
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
          
          // Indicador flotante de potenciador activo
          Consumer<BoosterProvider>(
            builder: (context, boosterProvider, child) {
              print('BoosterProvider state: hasActive=${boosterProvider.hasActiveBooster}');
              if (boosterProvider.activeBooster != null) {
                print('Active booster: ${boosterProvider.activeBooster!.name}');
                print('Remaining time: ${boosterProvider.getFormattedRemainingTime()}');
              }
              
              return ActiveBoosterIndicator(
                isFloating: true,
                onTap: () {
                  _showBoosterInfo(context);
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userRole: user.role,
      ),
    );
  }

  void _showBoosterInfo(BuildContext context) {
    final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
    if (!boosterProvider.hasActiveBooster) {
      print('No active booster to show info for');
      return;
    }

    final booster = boosterProvider.activeBooster!;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.success,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Potenciador Activo',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                booster.name,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (booster.xpMultiplier > 1.0)
                    Column(
                      children: [
                        Icon(Icons.star, color: Colors.blue, size: 24),
                        Text(
                          'XP x${booster.xpMultiplier.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  if (booster.coinMultiplier > 1.0)
                    Column(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                        Text(
                          'Monedas x${booster.coinMultiplier.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tiempo restante: ${boosterProvider.getFormattedRemainingTime()}',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '¡Genial!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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