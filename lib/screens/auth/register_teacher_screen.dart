// Crear un nuevo archivo: lib/screens/auth/register_teacher_screen.dart

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

class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellphoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  int _currentStep = 1;
  int _totalSteps = 3;

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
    _cellphoneController.dispose();
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
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final cellphone = int.tryParse(_cellphoneController.text.trim()) ?? 0;
      final password = _passwordController.text.trim();
      
      // Llamar al AuthProvider para realizar el registro
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.registerTeacher(
        email,
        password,
        firstName,
        lastName,
        cellphone,
      );
      
      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Registro exitoso! Bienvenido a la Academia Espacial, Profesor.',
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
              AppRoutes.navigateToHomeAndClearStack(context);
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
            'Debes aceptar las reglas espaciales para unirte como profesor.',
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
          // Fondo espacial
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
                                      Icons.science_rounded,
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
          
          // Indicador de carga
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const LoadingIndicator(
                message: '¡Preparando tu estación espacial!',
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
        return '¡Únete como Profesor Espacial!';
      case 2:
        return '¡Información de Contacto!';
      case 3:
        return '¡Última Misión!';
      default:
        return '¡Regístrate!';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 1:
        return 'Crea tu perfil de profesor guía';
      case 2:
        return 'Datos para comunicarnos contigo';
      case 3:
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
        return _buildContactInfoStep();
      case 3:
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
            controller: _firstNameController,
            hintText: 'Tu nombre',
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
            controller: _lastNameController,
            hintText: 'Tu apellido',
            prefixIcon: Icons.badge_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu apellido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        FadeAnimation(
          delay: const Duration(milliseconds: 700),
          child: CustomTextField(
            controller: _emailController,
            hintText: 'Tu correo electrónico',
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
        const SizedBox(height: 30),
        // Botón para continuar
        FadeAnimation(
          delay: const Duration(milliseconds: 900),
          child: CustomButton(
            text: 'Continuar',
            onPressed: _nextStep,
            icon: Icons.arrow_forward_rounded,
            backgroundColor: const Color(0xFF00C853), // Verde
            height: 55,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Teléfono celular
        FadeAnimation(
          delay: const Duration(milliseconds: 500),
          child: CustomTextField(
            controller: _cellphoneController,
            hintText: 'Número de teléfono',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu número de teléfono';
              }
              if (value.trim().length < 8) {
                return 'Por favor ingresa un número válido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 30),
        
        // Botón para materias que enseña (solo visual, para mantener el paso UI)
        FadeAnimation(
          delay: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  '¿Qué materias enseñas?',
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSubjectChip('Matemáticas', true),
                    _buildSubjectChip('Ciencias', false),
                    _buildSubjectChip('Lenguaje', false),
                    _buildSubjectChip('Historia', false),
                    _buildSubjectChip('Arte', false),
                    const SizedBox(height: 8),
                    Text(
                      'Podrás configurar tus materias después del registro',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                delay: const Duration(milliseconds: 800),
                child: CustomButton(
                  text: 'Atrás',
                  onPressed: _previousStep,
                  isOutlined: true,
                  height: 55,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Botón para continuar
            Expanded(
              flex: 2,
              child: FadeAnimation(
                delay: const Duration(milliseconds: 900),
                child: CustomButton(
                  text: 'Continuar',
                  onPressed: _nextStep,
                  icon: Icons.arrow_forward_rounded,
                  backgroundColor: const Color(0xFF00C853), // Verde
                  height: 55,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectChip(String subject, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              // Solo visual
            },
            activeColor: AppColors.primary,
          ),
          Text(
            subject,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
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
        // Consejos de seguridad
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
                _buildPasswordTip('Incluye algún carácter especial (@,!,?)'),
                _buildPasswordTip('Incluye mayusculas y minusculas'),
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
                    'Acepto las reglas espaciales y prometo guiar a mis estudiantes en su aventura de aprendizaje.',
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
            // Continuación de lib/screens/auth/register_teacher_screen.dart

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
                  icon: Icons.science_rounded,
                  backgroundColor: const Color(0xFFFF5252), // Rojo - color secundario
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

  Widget _buildSpaceBackground(Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8E24AA), // Púrpura más científico
            const Color(0xFF7B1FA2), // Púrpura medio
            const Color(0xFF6A1B9A), // Púrpura oscuro
          ],
        ),
      ),
      child: Stack(
        children: [
          // Estrellas parpadeantes (puntos blancos)
          ..._generateStars(150, screenSize),
          // Planeta decorativo
          Positioned(
            top: screenSize.height * 0.15,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade900,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          // "Laboratorio" espacial decorativo
          Positioned(
            bottom: screenSize.height * 0.3,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade300,
                    Colors.teal.shade900,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 40,
                ),
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
}