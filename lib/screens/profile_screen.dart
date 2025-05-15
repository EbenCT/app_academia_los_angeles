// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../constants/asset_paths.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/animations/fade_animation.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/game/advanced_avatar_widget.dart';
import '../widgets/profile/advanced_avatar_customization_widget.dart';
import '../utils/app_dialogs.dart';

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
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: AdvancedAvatarCustomizationWidget(
            initialAvatar: avatarProvider.avatar,
            onAvatarUpdated: (avatarData) async {
              // Guardar los cambios del avatar
              if (authProvider.currentUser != null) {
                final success = await avatarProvider.updateMultipleFields(
                  authProvider.currentUser!.id, 
                  avatarData
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Avatar actualizado con éxito!')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar el avatar')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final avatarProvider = Provider.of<AvatarProvider>(context);
    final user = authProvider.currentUser;
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
      appBar: AppBar(
        title: Text(
          'Mi Perfil Espacial',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar y nombre
              FadeAnimation(
                delay: const Duration(milliseconds: 200),
                child: Center(
                  child: Column(
                    children: [
                      // Avatar
                      AdvancedAvatarWidget(
                        username: user.username,
                        level: user.level,
                        size: 140,
                        showLevel: false,
                        avatarData: avatar?.toJson(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nombre de usuario
                      Text(
                        user.username,
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
                        width: 240,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tarjeta de información personal
              FadeAnimation(
                delay: const Duration(milliseconds: 400),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
                ),
              ),
              
              // Botón de cerrar sesión
              const SizedBox(height: 40),
              FadeAnimation(
                delay: const Duration(milliseconds: 600),
                child: _buildLogoutButton(context, authProvider),
              ),
            ],
          ),
        ),
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