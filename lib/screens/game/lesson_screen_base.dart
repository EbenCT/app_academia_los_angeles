// lib/screens/game/lesson_screen_base.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';

/// Pantalla base para lecciones interactivas
/// Esta clase puede ser extendida por diferentes lecciones
class LessonScreenBase extends StatefulWidget {
  final String title;
  final int totalSteps;
  final List<Widget> steps;
  final String completionRoute;
  final int completionPoints;
  final String completionMessage;

  const LessonScreenBase({
    Key? key,
    required this.title,
    required this.totalSteps,
    required this.steps,
    required this.completionRoute,
    this.completionPoints = 30,
    this.completionMessage = '¡Felicidades! Has completado la lección.',
  }) : super(key: key);

  @override
  State<LessonScreenBase> createState() => _LessonScreenBaseState();
}

class _LessonScreenBaseState extends State<LessonScreenBase> {
  // Controlador para las páginas de la lección
  late final PageController _pageController;
  
  // Estado actual
  int _currentPage = 0;
  bool _isCompleting = false;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Método para avanzar a la siguiente página
  void _nextPage() {
    if (_currentPage < widget.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Si estamos en la última página, completamos la lección
      _completeLesson();
    }
  }
  
  // Método para retroceder a la página anterior
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Método para completar la lección
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.completionMessage} +${widget.completionPoints} puntos',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Navegar a la siguiente pantalla
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, widget.completionRoute);
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.secondary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior
                _buildTopBar(),
                
                // Contenido de la lección
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: widget.steps,
                  ),
                ),
                
                // Barra inferior con botones de navegación
                _buildNavigationBar(),
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
  
  // Widget para la barra superior
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botón para volver
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          
          const Spacer(),
          
          // Título de la lección
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Indicador de página
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1}/${widget.totalSteps}',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para la barra de navegación inferior
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            )
          else
            const SizedBox(width: 120),
          
          // Indicador de progreso
          Row(
            children: List.generate(widget.totalSteps, (index) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          
          // Botón para siguiente página o completar
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: Icon(_currentPage == widget.totalSteps - 1 ? Icons.check : Icons.arrow_forward),
            label: Text(_currentPage == widget.totalSteps - 1 ? '¡Completar!' : 'Siguiente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == widget.totalSteps - 1 ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}