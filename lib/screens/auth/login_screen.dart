// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../config/routes.dart';
import '../../constants/asset_paths.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/bounce_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    // Validar formulario
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim()
      );
      if (success && mounted) {
        // Navegar a la pantalla principal si el login fue exitoso
        AppRoutes.navigateToHomeAndClearStack(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final error = authProvider.error;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo espacial con estrellas animadas
          _buildSpaceBackground(size),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Añadir esto
                      children: [
                        const SizedBox(height: 40),                       
                        // Logo del colegio con efecto de rebote
                        BounceAnimation(
                          child: Hero(
                            tag: 'school_logo',
                            child: Container(
                              width: 180,
                              height: 180,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AssetPaths.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Título con animación
                        FadeAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            '¡Hola Explorador Espacial!',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtítulo 
                        FadeAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            '¡Ingresa tus datos para comenzar tu misión espacial!',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 16,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Tarjeta de formulario
                        Flexible(  // Cambiar Expanded por Flexible
                          fit: FlexFit.loose,  // Añadir esta línea
                          child: FadeAnimation(
                            delay: const Duration(milliseconds: 400),
                            slideOffset: const Offset(0, 30),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDarkMode 
                                    ? AppColors.darkSurface.withOpacity(0.95) 
                                    : Colors.white.withOpacity(0.95),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Mensaje de error si existe
                                  if (error != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              error,
                                              style: TextStyle(
                                                fontFamily: 'Comic Sans MS',
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  
                                  // Campo de usuario/email con CustomTextField
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 500),
                                    child: CustomTextField(
                                      controller: _emailController,
                                      hintText: 'Nombre de usuario o correo',
                                      prefixIcon: Icons.person_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Por favor ingresa tu nombre de usuario o correo';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Campo de contraseña con CustomTextField
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 600),
                                    child: CustomTextField(
                                      controller: _passwordController,
                                      hintText: 'Contraseña secreta',
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: !_isPasswordVisible,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible 
                                              ? Icons.visibility 
                                              : Icons.visibility_off,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Por favor ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Recordarme y olvidé contraseña
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 700),
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        // Checkbox de recordarme
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              activeColor: AppColors.primary,
                                            ),
                                            Text(
                                              'Recordarme',
                                              style: TextStyle(
                                                fontFamily: 'Comic Sans MS',
                                                fontSize: 14,
                                                color: isDarkMode 
                                                    ? Colors.white70 
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        // Olvidé contraseña
                                        TextButton(
                                          onPressed: () {
                                            // TODO: Implementar recuperación de contraseña
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Pide ayuda a tu profesor para recuperar tu contraseña',
                                                  style: TextStyle(fontFamily: 'Comic Sans MS'),
                                                ),
                                                backgroundColor: AppColors.info,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '¿Olvidaste tu contraseña?',
                                            style: TextStyle(
                                              fontFamily: 'Comic Sans MS',
                                              fontSize: 14,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Botón de iniciar sesión con CustomButton
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 800),
                                    child: CustomButton(
                                      text: '¡Comenzar Aventura!',
                                      onPressed: _login,
                                      icon: Icons.rocket_launch_rounded,
                                      isLoading: isLoading,
                                      height: 55,
                                      backgroundColor: const Color(0xFFFFD700), // Amarillo espacial
                                      textColor: const Color(0xFF003366), // Azul oscuro
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Separador O
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 900),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: isDarkMode 
                                                ? Colors.white30 
                                                : Colors.black26,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'O',
                                            style: TextStyle(
                                              fontFamily: 'Comic Sans MS',
                                              fontSize: 16,
                                              color: isDarkMode 
                                                  ? Colors.white70 
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: isDarkMode 
                                                ? Colors.white30 
                                                : Colors.black26,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Botón de registro con CustomButton
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 1000),
                                    child: CustomButton(
                                      text: '¡Regístrate para unirte a la misión!',
                                      onPressed: () {
                                        _showRoleSelectionDialog(context);
                                      },
                                      isOutlined: true,
                                      icon: Icons.how_to_reg_rounded,
                                      height: 55,
                                      backgroundColor: const Color(0xFF0066CC), // Azul
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Indicador de carga
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const LoadingIndicator(
                message: '¡Preparando tu nave espacial!',
                useAstronaut: true,
                size: 180,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpaceBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A237E), // Azul oscuro espacial
            const Color(0xFF311B92), // Púrpura espacial
            const Color(0xFF4A148C), // Morado espacial
          ],
        ),
      ),
      child: Stack(
        children: [
          // Estrellas parpadeantes (puntos blancos)
          ..._generateStars(200, size),
          
          // Planeta decorativo
          Positioned(
            top: size.height * 0.1,
            right: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade300,
                    Colors.orange.shade700,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          
          // Planeta pequeño decorativo
          Positioned(
            bottom: size.height * 0.15,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.lightBlue.shade300,
                    Colors.lightBlue.shade700,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para generar estrellas aleatorias
List<Widget> _generateStars(int count, Size screenSize) {
  final List<Widget> stars = [];
  for (int i = 0; i < count; i++) {
    final double left = (i * 17) % screenSize.width;
    final double top = (i * 23) % screenSize.height;
    final double starSize = (i % 3) * 0.5 + 1.0; // Tamaño entre 1.0 y 2.5
    
    stars.add(
      Positioned(
        left: left,
        top: top,
        child: _buildStar(starSize),
      ),
    );
  }
  return stars;
}

  // Construye una estrella con animación de brillo
  Widget _buildStar(double size) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: Duration(milliseconds: 1000 + (size * 500).toInt()),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  
  void _showRoleSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                AssetPaths.astronautAnimation,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Cuál es tu rol en la misión espacial?',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Opción Estudiante
              _buildRoleOption(
                context: context,
                title: 'Estudiante Explorador',
                description: 'Para pequeños aventureros espaciales',
                icon: Icons.school_rounded,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  AppRoutes.navigateTo(context, AppRoutes.register);
                },
              ),
              const SizedBox(height: 16),
              // Opción Profesor
              _buildRoleOption(
                context: context,
                title: 'Profesor Guía',
                description: 'Para comandantes de la misión',
                icon: Icons.science_rounded,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pop(context);
                  AppRoutes.navigateTo(context, AppRoutes.registerTeacher);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRoleOption({
  required BuildContext context,
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
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
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: color,
            size: 20,
          ),
        ],
      ),
    ),
  );
}
}