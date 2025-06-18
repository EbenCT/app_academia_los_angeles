// lib/screens/home/home_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/coin_provider.dart';
import '../../services/lesson_progress_service.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../theme/app_colors.dart';
import '../../widgets/home/welcome_banner_widget.dart';
import '../../widgets/home/course_card_widget.dart';
import '../../widgets/home/daily_challenge_widget.dart';
import '../../widgets/home/progress_summary_widget.dart';
import '../../widgets/pet/floating_pet_widget.dart';
import '../../widgets/common/section_title.dart';
import '../../utils/app_icons.dart';
import '../../widgets/transition/subject_to_topics_transition.dart';
import '../shop/active_booster_indicator.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<String, dynamic>? _overallProgress;

  @override
  void initState() {
    super.initState();
    _loadOverallProgress();
  }

  Future<void> _loadOverallProgress() async {
    if (!mounted) return;
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final subjects = studentProvider.subjects;
    
    if (subjects.isNotEmpty) {
      final progress = await LessonProgressService.getOverallProgress(subjects);
      if (mounted) {
        setState(() {
          _overallProgress = progress;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Obtener datos del StudentProvider
    final studentProvider = Provider.of<StudentProvider>(context);
    final studentLevel = studentProvider.level;
    final studentXp = studentProvider.xp;
    final subjects = studentProvider.subjects;

    return SafeArea(
      child: Stack(
        children: [
          // Contenido principal
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              if (!mounted) return;
              await studentProvider.refreshStudentData();
              if (mounted) {
                await _loadOverallProgress();
              }
            },
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
                        // Indicador de potenciador activo (inline)
                        ActiveBoosterIndicator(isFloating: false),
                        
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
                              await studentProvider.completeChallenge(50, context: context);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Título de sección con estadísticas
                        Row(
                          children: [
                            Expanded(
                              child: SectionTitle(
                                title: 'Tus materias',
                                color: AppColors.accent,
                              ),
                            ),
                            if (_overallProgress != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColors.accent.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${_overallProgress!['percentage']}% completado',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                          ],
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
                        const SizedBox(height: 100), // Espacio para el bottom navigation
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Widget flotante de mascota
          _buildFloatingPet(),
        ],
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

  Widget _buildAppBar(bool isDarkMode, String username, ThemeProvider themeProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      automaticallyImplyLeading: false,
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
            // Mostrar notificaciones o mensaje
          },
        ),
      ],
    );
  }

  Widget _buildSubjectsSection(List<dynamic> subjects) {
    return SizedBox(
      height: 200,
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
                    icon: icon,
                    color: color,
                    subjectId: subject.id, // Pasamos el ID de la materia
                    // REEMPLAZAR EL onTap: del CourseCardWidget con esto:
                    onTap: () async {
                      // Usar el nuevo sistema de transición
                      await SubjectToTopicsTransition.navigateToSubjectTopics(
                        context,
                        subject,
                      );
                      
                      // Recargar progreso cuando se regrese
                      _loadOverallProgress();
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