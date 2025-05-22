import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../theme/app_colors.dart';
import '../../config/routes.dart';
import '../../widgets/home/welcome_banner_widget.dart';
import '../../widgets/home/course_card_widget.dart';
import '../../widgets/home/daily_challenge_widget.dart';
import '../../widgets/home/progress_summary_widget.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/navigation/app_bottom_navigation.dart';
import '../../utils/app_icons.dart';

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
    
    // Usar addPostFrameCallback para cargar datos después de que el primer frame se haya completado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
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
    
    // Cargar datos del estudiante
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.refreshStudentData();
    
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
    
    // Obtener datos del StudentProvider
    final studentProvider = Provider.of<StudentProvider>(context);
    final studentLevel = studentProvider.level;
    final studentXp = studentProvider.xp;
    final subjects = studentProvider.subjects;

    // Si el usuario es estudiante, verificar si está en un aula
    if (user != null && user.role == 'student') {
      // Si está cargando datos o no hay usuario, mostrar pantalla de carga
      if (_isLoading || studentProvider.isLoading) {
        return _buildLoadingScreen('Cargando tu mundo de aventuras...');
      }

      // Si el estudiante no tiene aula, redirigir a la pantalla de unirse
      if (!studentProvider.hasClassroom) {
        // Usando Future.microtask para evitar errores de navegación durante el build
        Future.microtask(() {
          AppRoutes.navigateReplacementTo(context, AppRoutes.joinClassroom);
        });
        // Mientras tanto, mostrar un loading
        return _buildLoadingScreen('Preparando tu nave espacial...');
      }
    }

    // Si no es estudiante o ya tiene aula, continuar con el HomeScreen normal
    if (_isLoading || user == null) {
      return _buildLoadingScreen('Cargando tu mundo de aventuras...');
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
              _buildAppBar(isDarkMode, user.username, themeProvider),
              
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
                          level: studentLevel,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Desafío diario
                      FadeAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: DailyChallengeWidget(
                          onComplete: () async {
                            // Actualizar los puntos al completar un desafío
                            await studentProvider.completeChallenge(50);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título de sección
                      SectionTitle(
                        title: 'Tus materias',
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      // Lista horizontal de materias del estudiante
                      _buildSubjectsSection(subjects),
                      const SizedBox(height: 24),
                      // Título de sección
                      SectionTitle(
                        title: 'Tu progreso espacial',
                      ),
                      const SizedBox(height: 16),
                      // Resumen de progreso
                      FadeAnimation(
                        delay: const Duration(milliseconds: 500),
                        child: ProgressSummaryWidget(
                          points: studentXp,
                          level: studentLevel,
                          streakDays: 5, // Valor fijo por ahora
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        userRole: user.role,
      ),
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

  Widget _buildAppBar(bool isDarkMode, String username, ThemeProvider themeProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: FadeAnimation(
          child: Text(
            '¡Hola, $username!',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    );
  }

  Widget _buildSubjectsSection(List<dynamic> subjects) {
    return SizedBox(
      height: 180,
      child: FadeAnimation(
        delay: const Duration(milliseconds: 400),
        child: subjects.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  // Asignar un icono basado en el nombre de la materia
                  final IconData icon = AppIcons.getCourseIcon(subject.name);
                  // Asignar un color basado en el índice
                  final color = AppIcons.getCourseColor(index);
                  
                  return CourseCardWidget(
                    title: subject.name,
                    progress: 0.0, // Por ahora sin progreso
                    icon: icon,
                    color: color,
                    onTap: () {
                      // Navegar a la pantalla de lecciones de la materia
                      Navigator.pushNamed(
                        context, 
                        '/subject-lessons',
                        arguments: subject,
                      );
                    },
                  );
                },
              )
            : _buildNoSubjectsMessage(),
      ),
    );
  }
  
  Widget _buildNoSubjectsMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay materias disponibles',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Habla con tu profesor para que configure las materias',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}