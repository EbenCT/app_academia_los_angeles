// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/animations/fade_animation.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../config/routes.dart';
import '../../../widgets/home/welcome_banner_widget.dart';
import '../../../widgets/home/course_card_widget.dart';
import '../../../widgets/home/achievement_preview_widget.dart';
import '../../../widgets/home/daily_challenge_widget.dart';
import '../../../widgets/home/progress_summary_widget.dart';
import '../../widgets/common/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulamos una carga de datos
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
      // Si el usuario es estudiante, verificar si está en un aula
  if (user != null && user.role == 'student') {
    final studentProvider = Provider.of<StudentProvider>(context);
    
    // Si está cargando datos o no hay usuario, mostrar pantalla de carga
    if (_isLoading || studentProvider.isLoading) {
      return Scaffold(
        body: LoadingIndicator(
          message: 'Cargando tu mundo de aventuras...',
          useAstronaut: true,
          size: 150,
        ),
      );
    }
    
    // Si el estudiante no tiene aula, redirigir a la pantalla de unirse
    if (!studentProvider.hasClassroom) {
      // Usando Future.microtask para evitar errores de navegación durante el build
      Future.microtask(() {
        AppRoutes.navigateReplacementTo(context, AppRoutes.joinClassroom);
      });
      
      // Mientras tanto, mostrar un loading
      return Scaffold(
        body: LoadingIndicator(
          message: 'Preparando tu nave espacial...',
          useAstronaut: true,
          size: 150,
        ),
      );
    }
  }
  
  // Si no es estudiante o ya tiene aula, continuar con el HomeScreen normal
  if (_isLoading || user == null) {
    return Scaffold(
      body: LoadingIndicator(
        message: 'Cargando tu mundo de aventuras...',
        useAstronaut: true,
        size: 150,
      ),
    );
  }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadUserData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar personalizada
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeAnimation(
                    child: Text(
                      '¡Hola, ${user.username}!',
                      style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡No tienes notificaciones nuevas!', 
                            style: TextStyle(fontFamily: 'Comic Sans MS')
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Banner de bienvenida
                      FadeAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: WelcomeBannerWidget(
                          username: user.username,
                          level: user.level,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Desafío diario
                      FadeAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: DailyChallengeWidget(
                          onComplete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡Has completado tu desafío diario! +50 puntos', 
                                  style: TextStyle(fontFamily: 'Comic Sans MS')
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Título de sección
                      _buildSectionTitle('Tus cursos espaciales'),
                      
                      const SizedBox(height: 16),
                      
                      // Lista horizontal de cursos
                      SizedBox(
                        height: 180,
                        child: FadeAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CourseCardWidget(
                                title: 'Matemáticas',
                                progress: 0.7,
                                icon: Icons.calculate,
                                color: Colors.blue,
                                onTap: () {
                                  AppRoutes.navigateTo(context, AppRoutes.courses);
                                },
                              ),
                              CourseCardWidget(
                                title: 'Ciencias',
                                progress: 0.4,
                                icon: Icons.science,
                                color: Colors.green,
                                onTap: () {
                                  AppRoutes.navigateTo(context, AppRoutes.courses);
                                },
                              ),
                              CourseCardWidget(
                                title: 'Lenguaje',
                                progress: 0.85,
                                icon: Icons.menu_book,
                                color: Colors.orange,
                                onTap: () {
                                  AppRoutes.navigateTo(context, AppRoutes.courses);
                                },
                              ),
                              CourseCardWidget(
                                title: 'Historia',
                                progress: 0.2,
                                icon: Icons.history_edu,
                                color: Colors.purple,
                                onTap: () {
                                  AppRoutes.navigateTo(context, AppRoutes.courses);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Título de sección
                      _buildSectionTitle('Tu progreso espacial'),
                      
                      const SizedBox(height: 16),
                      
                      // Resumen de progreso
                      FadeAnimation(
                        delay: const Duration(milliseconds: 500),
                        child: ProgressSummaryWidget(
                          points: user.points,
                          level: user.level,
                          streakDays: 5, // Ejemplo
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Título de sección
                      _buildSectionTitle('Logros recientes'),
                      
                      const SizedBox(height: 16),
                      
                      // Preview de logros
                      FadeAnimation(
                        delay: const Duration(milliseconds: 600),
                        child: AchievementPreviewWidget(
                          achievements: [
                            {
                              'title': 'Explorador espacial',
                              'description': 'Completaste tu primer misión',
                              'icon': Icons.rocket_launch,
                              'unlocked': true,
                            },
                            {
                              'title': 'Matemático junior',
                              'description': 'Completaste 10 ejercicios de matemáticas',
                              'icon': Icons.calculate,
                              'unlocked': true,
                            },
                            {
                              'title': 'Científico curioso',
                              'description': 'Realizaste tu primer experimento',
                              'icon': Icons.science,
                              'unlocked': false,
                            },
                          ],
                          onSeeMoreTap: () {
                            AppRoutes.navigateTo(context, AppRoutes.achievements);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      // Añadir esto a tu HomeScreen
FadeAnimation(
  delay: const Duration(milliseconds: 700),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.primary.withOpacity(0.3),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Text(
          'Mini-juego: Rescate de Alturas',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Aprende sobre números enteros rescatando amigos a diferentes alturas',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: '¡Jugar ahora!',
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.integerRescueGame);
          },
          icon: Icons.videogame_asset,
          backgroundColor: AppColors.secondary,
          height: 50,
        ),
      ],
    ),
  ),
),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.darkSurface 
              : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Comic Sans MS',
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Comic Sans MS',
          ),
          items: const [
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
          ],
          onTap: (index) {
            if (index == 0) {
              // Ya estamos en inicio
            } else if (index == 1) {
              AppRoutes.navigateTo(context, AppRoutes.courses);
            } else if (index == 2) {
              AppRoutes.navigateTo(context, AppRoutes.achievements);
            } else if (index == 3) {
              AppRoutes.navigateTo(context, AppRoutes.profile);
            }
          },
        ),
      ),
    );
  }
}