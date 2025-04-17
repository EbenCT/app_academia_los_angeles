// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedRole;
  final List<String> _roles = [AppConstants.roleStudent, AppConstants.roleTeacher];

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _register() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    // Validar formulario
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _selectedRole == AppConstants.roleTeacher ? 'TEACHER' : 'STUDENT',
      );

      if (success && mounted) {
        // Navegar a la pantalla principal si el registro fue exitoso
        AppRoutes.navigateToHomeAndClearStack(context);
      }
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un rol')),
      );
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
          // Fondo con gradiente colorido
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
                        /*const SizedBox(height: 40),
                        
                        // Logo del colegio
                        _buildLogo(),
                        
                        const SizedBox(height: 20),*/
                        
                        // Tarjeta de registro
                        _buildRegisterCard(error),
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
                message: 'Creando tu cuenta...',
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
            Color(0xFFE63946), // Rojo
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

  Widget _buildRegisterCard(String? error) {
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
                // Titulo
                FadeAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppConstants.registerTitle,
                    style: GoogleFonts.comicNeue(
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
                      style: GoogleFonts.comicNeue(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Campo de nombre
                FadeAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: CustomTextField(
                    controller: _firstNameController,
                    hintText: AppConstants.firstNameHint,
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.invalidName;
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de apellido
                FadeAnimation(
                  delay: const Duration(milliseconds: 550),
                  child: CustomTextField(
                    controller: _lastNameController,
                    hintText: AppConstants.lastNameHint,
                    prefixIcon: Icons.people,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.invalidName;
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de correo electrónico
                FadeAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: AppConstants.emailHint,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredField;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return AppConstants.invalidEmail;
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de contraseña
                FadeAnimation(
                  delay: const Duration(milliseconds: 650),
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: AppConstants.passwordHint,
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
                      if (value.length < 6) {
                        return AppConstants.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de confirmar contraseña
                FadeAnimation(
                  delay: const Duration(milliseconds: 700),
                  child: CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirmar Contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredField;
                      }
                      if (value != _passwordController.text) {
                        return AppConstants.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Selector de rol
                FadeAnimation(
                  delay: const Duration(milliseconds: 750),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkInputBackground
                          : AppColors.inputBackground,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                      icon: Text(
                        AppConstants.selectRole,
                        style: GoogleFonts.comicNeue(),
                      ),
                    ),
                    value: _selectedRole,
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: GoogleFonts.comicNeue()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona un rol';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botón de registro
                FadeAnimation(
                  delay: const Duration(milliseconds: 800),
                  child: CustomButton(
                    text: AppConstants.registerButton,
                    onPressed: _register,
                    icon: Icons.how_to_reg,
                    backgroundColor: const Color(0xFFFFD700), // Amarillo
                    textColor: const Color(0xFF003366), // Azul oscuro
                    height: 60,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Enlace para iniciar sesión
                FadeAnimation(
                  delay: const Duration(milliseconds: 850),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.alreadyHaveAccount,
                        style: GoogleFonts.comicNeue(
                          fontSize: 16,
                          color: const Color(0xFF003366), // Azul oscuro
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateReplacementTo(context, AppRoutes.login);
                        },
                        child: Text(
                          AppConstants.loginInstead,
                          style: GoogleFonts.comicNeue(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE63946), // Rojo
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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