// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../constants/asset_paths.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/space_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  int _currentStep = 1;
  int _totalSteps = 2; // Reducido de 3 a 2 pasos al eliminar la personalización de avatar

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
    _nameController.dispose();
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
    if (_formKey.currentState!.validate() && _acceptTerms) {
      // Crear nombre y apellido a partir del nombre completo
      final nameParts = _nameController.text.trim().split(' ');
      String firstName = nameParts.first;
      String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Si no hay apellido, usar un valor predeterminado
      if (lastName.isEmpty) {
        lastName = "Explorador";
      }
      // Llamar al AuthProvider para realizar el registro de estudiante
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.registerStudent(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        firstName,
        lastName,
      );
      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Registro exitoso! Tu aventura espacial comenzará pronto.',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navegar al home directamente o al login según la configuración
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (authProvider.isAuthenticated) {
              // Si el registro también inicia sesión automáticamente
              AppRoutes.navigateToMainAndClearStack(context);
            } else {
              // Si requiere login manual después del registro
              AppRoutes.navigateReplacementTo(context, AppRoutes.login);
            }
          }
        });
      } else if (!success && mounted) {
        // Mostrar mensaje de error
        final errorMsg = authProvider.error ?? 'No se pudo completar el registro';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else if (!_acceptTerms) {
      // Mensaje si no aceptó los términos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debes aceptar las reglas espaciales para unirte a la misión.',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Usamos el widget SpaceBackground
          SpaceBackground.forRegister(
            child: SafeArea(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barra superior con botón atrás
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Botón atrás
                                IconButton(
                                  onPressed: () {
                                    if (_currentStep > 1) {
                                      _previousStep();
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                ),
                                // Indicador de pasos
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.rocket_launch,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Paso $_currentStep de $_totalSteps',
                                        style: TextStyle(
                                          fontFamily: 'Comic Sans MS',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Espaciador para mantener centrado el indicador
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Logo pequeño
                          Hero(
                            tag: 'school_logo',
                            child: Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AssetPaths.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Título con animación
                          FadeAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              _getStepTitle(),
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 24,
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
                          const SizedBox(height: 10),
                          // Subtítulo
                          FadeAnimation(
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              _getStepSubtitle(),
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
                          // Tarjeta con formulario por pasos
                          Flexible(
                            fit: FlexFit.loose,
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
                                child: _buildCurrentStepContent(),
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

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return '¡Únete a la Aventura!';
      case 2:
        return '¡Última Misión!';
      default:
        return '¡Regístrate!';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 1:
        return 'Cuéntanos sobre ti para comenzar';
      case 2:
        return 'Establece tu contraseña secreta';
      default:
        return 'Ingresa tus datos';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildPasswordStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campos de información personal
        FadeAnimation(
          delay: const Duration(milliseconds: 500),
          child: CustomTextField(
            controller: _nameController,
            hintText: 'Tu nombre de explorador',
            prefixIcon: Icons.badge_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        FadeAnimation(
          delay: const Duration(milliseconds: 600),
          child: CustomTextField(
            controller: _emailController,
            hintText: 'Tu correo o el de tus padres',
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un correo';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        // Fecha de nacimiento simplificada para niños
        FadeAnimation(
          delay: const Duration(milliseconds: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  '¿Cuántos años tienes?',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10, // Edades de 5 a 14 años
                  itemBuilder: (context, index) {
                    final age = index + 5;
                    return GestureDetector(
                      onTap: () {
                        // Seleccionar edad
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: age == 10
                              ? AppColors.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black26
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: age == 10
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$age',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: age == 10
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Selección de curso
        FadeAnimation(
          delay: const Duration(milliseconds: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  '¿En qué grado estás?',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: '4to Grado',
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    iconSize: 30,
                    elevation: 16,
                    dropdownColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.white,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onChanged: (newValue) {
                      // Actualizar grado
                    },
                    items: <String>[
                      '3er Grado',
                      '4to Grado',
                      '5to Grado',
                      '6to Grado',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Botón para continuar
        FadeAnimation(
          delay: const Duration(milliseconds: 900),
          child: CustomButton(
            text: 'Continuar a contraseña',
            onPressed: _nextStep,
            icon: Icons.arrow_forward_rounded,
            backgroundColor: const Color(0xFF00C853), // Verde
            height: 55,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    // Nota: La validación de contraseña debe coincidir con los requisitos del backend
    // Por lo general, se requiere al menos 6 caracteres, y puede tener reglas adicionales
    // como incluir letras mayúsculas, minúsculas, números y caracteres especiales.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campos de contraseña
        FadeAnimation(
          delay: const Duration(milliseconds: 500),
          child: CustomTextField(
            controller: _passwordController,
            hintText: 'Contraseña secreta',
            prefixIcon: Icons.lock_rounded,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
                size: 22,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa una contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        FadeAnimation(
          delay: const Duration(milliseconds: 600),
          child: CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirma tu contraseña',
            prefixIcon: Icons.lock_rounded,
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
                size: 22,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        // Consejos de seguridad amigables para niños
        FadeAnimation(
          delay: const Duration(milliseconds: 700),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Consejos para tu contraseña:',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPasswordTip('Usa letras y números'),
                _buildPasswordTip('No uses tu nombre'),
                _buildPasswordTip('No la compartas con nadie'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Aceptar términos y condiciones
        FadeAnimation(
          delay: const Duration(milliseconds: 800),
          child: Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _acceptTerms = !_acceptTerms;
                    });
                  },
                  child: Text(
                    'Acepto las reglas espaciales y prometo ser un buen explorador.',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Botones de navegación
        Row(
          children: [
            // Botón para regresar
            Expanded(
              flex: 1,
              child: FadeAnimation(
                delay: const Duration(milliseconds: 900),
                child: CustomButton(
                  text: 'Atrás',
                  onPressed: _previousStep,
                  isOutlined: true,
                  height: 55,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Botón para registrarse
            Expanded(
              flex: 2,
              child: FadeAnimation(
                delay: const Duration(milliseconds: 1000),
                child: CustomButton(
                  text: '¡Registrarme!',
                  onPressed: _register,
                  icon: Icons.rocket_launch_rounded,
                  backgroundColor: const Color(0xFFFFD700), // Amarillo
                  textColor: const Color(0xFF003366), // Azul oscuro
                  height: 55,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.info,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            tip,
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
    );
  }
}
