// lib/screens/game/lesson_screen_base.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/student_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../constants/asset_paths.dart';

/// Pantalla base mejorada para lecciones interactivas
/// Esta clase puede ser extendida por diferentes lecciones
class LessonScreenBase extends StatefulWidget {
  final String title;
  final IconData? icon;
  final LinearGradient? titleGradient;
  final int totalSteps;
  final List<Widget> steps;
  final String completionRoute;
  final int completionPoints;
  final String completionMessage;
  final String? backgroundAsset;
  final Color? nextButtonColor;
  final Color? previousButtonColor;

  const LessonScreenBase({
    Key? key,
    required this.title,
    this.icon,
    this.titleGradient,
    required this.totalSteps,
    required this.steps,
    required this.completionRoute,
    this.completionPoints = 30,
    this.completionMessage = '¡Felicidades! Has completado la lección.',
    this.backgroundAsset,
    this.nextButtonColor,
    this.previousButtonColor,
  }) : super(key: key);

  @override
  State<LessonScreenBase> createState() => _LessonScreenBaseState();
}

class _LessonScreenBaseState extends State<LessonScreenBase> with SingleTickerProviderStateMixin {
  // Controlador para las páginas de la lección
  late final PageController _pageController;
  // Controlador para animaciones
  late final AnimationController _animationController;
  // Estado actual
  int _currentPage = 0;
  bool _isCompleting = false;
  
  // Para el efecto de página al dar siguiente o anterior
  bool _isNavigatingForward = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Método para avanzar a la siguiente página con animación
  void _nextPage() {
    setState(() {
      _isNavigatingForward = true;
    });
    
    if (_currentPage < widget.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      // Reproducir sonido de cambio de página si es necesario
    } else {
      // Si estamos en la última página, completamos la lección
      _completeLesson();
    }
  }

  // Método para retroceder a la página anterior con animación
  void _previousPage() {
    setState(() {
      _isNavigatingForward = false;
    });
    
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Método para completar la lección con animación y efectos
  Future<void> _completeLesson() async {
    setState(() {
      _isCompleting = true;
    });

    // Llamar al provider para guardar el progreso
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.completeChallenge(widget.completionPoints);

    setState(() {
      _isCompleting = false;
    });

    // Mostrar mensaje y dirigir a la siguiente pantalla
    if (mounted) {
      _showCompletionDialog();
    }
  }
  
  // Muestra un diálogo de felicitación al completar la lección
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animación de éxito
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset(
                    AssetPaths.successAnimation,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Lección Completada!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black26,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.completionMessage,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.star,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.completionPoints} puntos',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navegar a la siguiente pantalla
                    Navigator.pushReplacementNamed(context, widget.completionRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '¡Vamos a jugar!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colores personalizados o predeterminados
    final nextBtnColor = widget.nextButtonColor ?? AppColors.primary;
    final prevBtnColor = widget.previousButtonColor ?? AppColors.primary.withOpacity(0.7);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo personalizado
          _buildBackground(isDarkMode),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior mejorada
                _buildTopBar(isDarkMode),
                
                // Contenido de la lección con efecto de transición
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: widget.steps.map((step) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: _isNavigatingForward 
                                    ? const Offset(0.2, 0.0) 
                                    : const Offset(-0.2, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: step,
                      );
                    }).toList(),
                  ),
                ),
                
                // Barra inferior con botones de navegación mejorados
                _buildNavigationBar(nextBtnColor, prevBtnColor),
              ],
            ),
          ),
          
          // Indicador de carga
          if (_isCompleting)
            Container(
              color: Colors.black45,
              child: const LoadingIndicator(
                message: '¡Completando la lección!',
                useAstronaut: true,
                size: 150,
              ),
            ),
        ],
      ),
    );
  }

  // Widget para el fondo con imagen o gradiente
  Widget _buildBackground(bool isDarkMode) {
    if (widget.backgroundAsset != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.backgroundAsset!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isDarkMode 
                ? Colors.black.withOpacity(0.7) 
                : Colors.white.withOpacity(0.8),
              BlendMode.dstATop,
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    AppColors.darkBackground,
                    AppColors.darkBackground.withOpacity(0.8),
                  ]
                : [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.secondary.withOpacity(0.05),
                  ],
          ),
        ),
      );
    }
  }

  // Widget para la barra superior mejorada
  Widget _buildTopBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: widget.titleGradient ?? 
            LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
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
          // Botón para volver
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              iconSize: 20,
            ),
          ),
          
          const Spacer(),
          
          // Título de la lección con icono
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon, 
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.title,
                style: const TextStyle(
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
            ],
          ),
          
          const Spacer(),
          
          // Indicador de página
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '${_currentPage + 1}/${widget.totalSteps}',
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para la barra de navegación inferior mejorada
  Widget _buildNavigationBar(Color nextColor, Color previousColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón para página anterior
          if (_currentPage > 0)
            ElevatedButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: ElevatedButton.styleFrom(
                backgroundColor: previousColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 3,
              ),
            )
          else
            const SizedBox(width: 120),
            
          // Indicador de progreso mejorado
          Row(
            children: List.generate(widget.totalSteps, (index) {
              return Container(
                width: index == _currentPage ? 16 : 10, // Más grande el actual
                height: index == _currentPage ? 16 : 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? nextColor
                      : index < _currentPage
                          ? nextColor.withOpacity(0.7) // Completados
                          : Colors.grey.withOpacity(0.3), // Pendientes
                  boxShadow: index == _currentPage
                      ? [
                          BoxShadow(
                            color: nextColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: index <= _currentPage
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: index == _currentPage ? 10 : 8,
                      )
                    : null,
              );
            }),
          ),
          
          // Botón para siguiente página
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: Icon(_currentPage == widget.totalSteps - 1 ? Icons.check : Icons.arrow_forward),
            label: Text(_currentPage == widget.totalSteps - 1 ? '¡Completar!' : 'Siguiente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == widget.totalSteps - 1 
                ? AppColors.success 
                : nextColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }
}