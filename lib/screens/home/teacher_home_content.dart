// lib/screens/home/teacher_home_content.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../../models/classroom_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/teacher/classroom_card_widget.dart';
import '../../widgets/teacher/create_classroom_dialog.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/app_card.dart';
import '../../utils/app_snackbars.dart';

class TeacherHomeContent extends StatelessWidget {
  const TeacherHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser!;
    final isDarkMode = themeProvider.isDarkMode;
    
    return ChangeNotifierProvider(
      create: (_) => ClassroomProvider(Provider.of<GraphQLClient>(context, listen: false)),
      child: Builder(
        builder: (context) {
          final classroomProvider = Provider.of<ClassroomProvider>(context);
          final classrooms = classroomProvider.classrooms;
          final isLoadingClassrooms = classroomProvider.isLoading;
          
          return SafeArea(
            child: Column(
              children: [
                // App Bar personalizada
                _buildAppBar(isDarkMode, user.username, themeProvider, context),
                
                // Contenido
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.secondary,
                    onRefresh: () async {
                      await classroomProvider.fetchTeacherClassrooms();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Banner de bienvenida para profesores
                          FadeAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: _buildTeacherWelcomeBanner(user.username),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Título de sección
                          SectionTitle(
                            title: 'Tus aulas espaciales',
                            color: AppColors.secondary,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Botón para crear nueva aula
                          _buildCreateClassroomButton(context),
                          
                          const SizedBox(height: 24),
                          
                          // Lista de aulas
                          if (isLoadingClassrooms)
                            Center(
                              child: LoadingIndicator(
                                message: 'Cargando tus aulas...',
                                size: 100,
                              ),
                            )
                          else if (classrooms.isEmpty)
                            FadeAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: _buildEmptyClassroomMessage(context),
                            )
                          else
                            FadeAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: classrooms.length,
                                itemBuilder: (context, index) {
                                  return ClassroomCardWidget(
                                    classroom: classrooms[index],
                                    onTap: () {
                                      _navigateToClassroomDetail(context, classrooms[index]);
                                    },
                                  );
                                },
                              ),
                            ),
                          
                          const SizedBox(height: 100), // Espacio para el bottom navigation
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAppBar(bool isDarkMode, String username, ThemeProvider themeProvider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8), // Reducido de 12 a 8
          Expanded( // Agregado Expanded para evitar overflow
            child: Text(
              '¡Hola, Profesor $username!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18, // Reducido de 20 a 18
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis, // Añadido para textos largos
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8), // Espaciado entre texto y botones
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: Colors.white,
              size: 20, // Reducido tamaño del icono
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            padding: EdgeInsets.all(4), // Reducido padding
            constraints: BoxConstraints(), // Sin restricciones mínimas
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 20, // Reducido tamaño del icono
            ),
            onPressed: () {
              AppSnackbars.showInfoSnackBar(
                context,
                message: '¡No tienes notificaciones nuevas!',
              );
            },
            padding: EdgeInsets.all(4), // Reducido padding
            constraints: BoxConstraints(), // Sin restricciones mínimas
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeacherWelcomeBanner(String username) {
    return AppCard.withGradient(
      colors: [
        AppColors.secondary,
        AppColors.primary,
      ],
      child: Stack(
        children: [
          // Elementos decorativos
          Positioned(
            top: 15,
            right: 20,
            child: Icon(
              Icons.science,
              color: Colors.white.withOpacity(0.3),
              size: 30,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            child: Icon(
              Icons.auto_stories,
              color: Colors.white.withOpacity(0.3),
              size: 25,
            ),
          ),
          
          // Animación de profesor
          Positioned(
            right: 10,
            bottom: 0,
            width: 120,
            height: 120,
            child: Lottie.asset(
              AssetPaths.astronautAnimation, // Reutilizamos la animación del astronauta
              fit: BoxFit.contain,
            ),
          ),
          
          // Texto de bienvenida
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡Bienvenido Profesor!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Guía Espacial',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '¡Guía a tus estudiantes en su aventura!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreateClassroomButton(BuildContext context) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () {
          _showCreateClassroomDialog(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                color: AppColors.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Crear nueva aula',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyClassroomMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.science,
            size: 80,
            color: AppColors.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Aún no tienes aulas!',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Crea tu primera aula espacial para comenzar a guiar a tus estudiantes en su aventura de aprendizaje.',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateClassroomDialog(context);
            },
            icon: Icon(Icons.add_circle_outline),
            label: Text(
              'Crear mi primera aula',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCreateClassroomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateClassroomDialog();
      },
    );
  }
  
  void _navigateToClassroomDetail(BuildContext context, ClassroomModel classroom) {
    // Aquí se implementaría la navegación a la pantalla de detalle del aula
    AppSnackbars.showInfoSnackBar(
      context,
      message: 'Función en desarrollo: Detalle del aula "${classroom.name}"',
    );
  }
}