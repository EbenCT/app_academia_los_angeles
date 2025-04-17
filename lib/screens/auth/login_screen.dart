import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../constants/app_constants.dart';
import '../../constants/asset_paths.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
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
    
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente colorido acorde al logo del colegio
          _buildColorfulBackground(),
          
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Logo del colegio
                        _buildLogo(),
                        const SizedBox(height: 20),
                        
                        // Tarjeta de login
                        _buildLoginCard(error),
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
              color: Colors.black26,
              child: const LoadingIndicator(
                message: 'Iniciando sesión...',
                useAstronaut: true,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildColorfulBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // Amarillo
            Color(0xFF0066CC), // Azul
            Color(0xFFE63946), // Toque de rojo
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
  
  Widget _buildLogo() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          AssetPaths.logo,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
  
  Widget _buildLoginCard(String? error) {
    return Expanded(
      child: Center(
        child: FadeAnimation(
          delay: const Duration(milliseconds: 300),
          slideOffset: const Offset(0, 30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                FadeAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    '¡Hola Explorador!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003366), // Azul oscuro
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mensaje de error si existe
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campo de correo electrónico usando CustomTextField
                FadeAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'Correo electrónico',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredField;
                      }
                      // Validación básica de email
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña usando CustomTextField
                FadeAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredField;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de inicio de sesión usando CustomButton
                FadeAnimation(
                  delay: const Duration(milliseconds: 700),
                  child: CustomButton(
                    text: 'Comenzar Aventura',
                    onPressed: _login,
                    icon: Icons.rocket_launch,
                    backgroundColor: const Color(0xFFFFD700), // Amarillo
                    textColor: const Color(0xFF003366), // Azul oscuro
                    height: 60,
                  ),
                ),
                const SizedBox(height: 16),

                // Recuperar contraseña
                FadeAnimation(
                  delay: const Duration(milliseconds: 800),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implementar recuperación de contraseña
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        color: Color(0xFF003366), // Azul oscuro
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de registro usando CustomButton
                FadeAnimation(
                  delay: const Duration(milliseconds: 900),
                  child: CustomButton(
                    text: '¡Registrarse!',
                    onPressed: () {
                      AppRoutes.navigateTo(context, AppRoutes.register);
                    },
                    isOutlined: true,
                    backgroundColor: const Color(0xFF0066CC), // Azul
                    textColor: const Color(0xFFE63946), // Rojo
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}