import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../constants/asset_paths.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/avatar_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/animations/fade_animation.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/game/avatar_widget.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/profile/avatar_customization_widget.dart';
import '../utils/app_dialogs.dart';
import '../utils/app_snackbars.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    
    // Cargar datos del usuario y del avatar
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // Cargar el avatar del usuario
      await avatarProvider.loadAvatar(authProvider.currentUser!.id);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAvatarCustomization() {
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: AvatarCustomizationWidget(
              initialAvatar: avatarProvider.avatar?.toJson(),
              onAvatarUpdated: (avatarData) async {
                // Guardar los cambios del avatar
                if (authProvider.currentUser != null) {
                  final success = await avatarProvider.updateAvatar(
                    authProvider.currentUser!.id, 
                    avatarData
                  );
                  
                  if (success && mounted) {
                    AppSnackbars.showSuccessSnackBar(
                      context, 
                      message: '¡Avatar actualizado con éxito!'
                    );
                  } else if (mounted) {
                    AppSnackbars.showErrorSnackBar(
                      context, 
                      message: avatarProvider.error ?? 'Error al actualizar el avatar'
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final avatarProvider = Provider.of<AvatarProvider>(context);
    final user = authProvider.currentUser;
    final isDarkMode = themeProvider.isDarkMode;
    final avatar = avatarProvider.avatar;

    if (_isLoading || user == null) {
      return Scaffold(
        body: LoadingIndicator(
          message: 'Cargando tu perfil espacial...',
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
              _buildAppBar(context, user, isDarkMode, themeProvider),
              
              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      
                      // Avatar y nombre
                      FadeAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Center(
                          child: Column(
                            children: [
                              AvatarWidget(
                                username: user.username,
                                level: user.level,
                                size: 140,
                                showLevel: user.role == 'student',
                                avatarData: avatar?.toJson(),
                              ),
                              const SizedBox(height: 16),
                              
                              // Botón para personalizar avatar
                              CustomButton(
                                text: avatar == null 
                                    ? 'Crear Avatar' 
                                    : 'Personalizar Avatar',
                                onPressed: _openAvatarCustomization,
                                icon: avatar == null ? Icons.add : Icons.edit,
                                backgroundColor: AppColors.secondary,
                                width: 200,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Rol del usuario
                      _buildRoleBadge(user, isDarkMode),
                      
                      const SizedBox(height: 30),
                      
                      // Tarjeta de información personal
                      FadeAnimation(
                        delay: const Duration(milliseconds: 400),
                        child: _buildInfoCard(context, user),
                      ),
                      const SizedBox(height: 20),
                      
                      // Tarjeta de estadísticas (solo para estudiantes)
                      if (user.role == 'student')
                        FadeAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: _buildStatsCard(context, user),
                        ),
                      
                      // Tarjeta de configuración
                      const SizedBox(height: 20),
                      FadeAnimation(
                        delay: const Duration(milliseconds: 600),
                        child: _buildSettingsCard(context, themeProvider),
                      ),
                      
                      // Botón de cerrar sesión
                      const SizedBox(height: 30),
                      FadeAnimation(
                        delay: const Duration(milliseconds: 700),
                        child: _buildLogoutButton(context, authProvider),
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
        currentIndex: 3,
        userRole: user.role,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel user, bool isDarkMode, ThemeProvider themeProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDarkMode 
        ? AppColors.darkPrimary 
        : (user.role == 'teacher' ? AppColors.secondary : AppColors.primary),
      flexibleSpace: FlexibleSpaceBar(
        title: FadeAnimation(
          child: Text(
            'Mi Perfil Espacial',
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
              colors: user.role == 'teacher'
                  ? [
                      AppColors.secondary,
                      AppColors.primary.withOpacity(0.7),
                    ]
                  : [
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
      ],
    );
  }
  
  Widget _buildRoleBadge(UserModel user, bool isDarkMode) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: (user.role == 'teacher' ? AppColors.secondary : AppColors.primary).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          user.role == 'teacher' ? 'Profesor Guía' : 'Estudiante Explorador',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: user.role == 'teacher' ? AppColors.secondary : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, UserModel user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: user.role == 'teacher' ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.email_rounded, 'Correo', user.email),
          const Divider(),
          _buildInfoRow(Icons.badge_rounded, 'Nombre', user.username),
          const Divider(),
          _buildInfoRow(Icons.verified_user_rounded, 'ID', user.id),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserModel user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Estadísticas',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.star, '${user.points}', 'Puntos', AppColors.star),
              _buildStatItem(Icons.trending_up, '${user.level}', 'Nivel', AppColors.primary),
              _buildStatItem(Icons.emoji_events, '${user.achievements.length}', 'Logros', AppColors.secondary),
            ],
          ),
          const SizedBox(height: 15),
          // Barra de progreso para el siguiente nivel
          _buildLevelProgressBar(user.level, context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar(int level, BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso al nivel ${level + 1}',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              '60%',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.6,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 15),
          // Cambiar tema
          _buildSettingRow(
            icon: isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            label: 'Cambiar Tema',
            color: AppColors.accent,
            trailingWidget: Switch(
              value: isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppColors.accent,
            ),
            onTap: () => themeProvider.toggleTheme(),
          ),
          const Divider(),
          // Opción de notificaciones (solo visual)
          _buildSettingRow(
            icon: Icons.notifications,
            label: 'Notificaciones',
            color: AppColors.accent,
            trailingWidget: Switch(
              value: true,
              onChanged: null,
              activeColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required Color color,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, authProvider),
        icon: Icon(Icons.exit_to_app_rounded),
        label: Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context: context,
      title: '¿Seguro que quieres salir de la nave espacial?',
      message: 'Tu misión espacial quedará pausada',
      confirmText: 'Salir',
      cancelText: 'Cancelar',
      confirmColor: Colors.redAccent,
      assetAnimation: AssetPaths.astronautAnimation,
    );
    
    if (confirm && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        AppRoutes.navigateReplacementTo(context, AppRoutes.login);
      }
    }
  }
}