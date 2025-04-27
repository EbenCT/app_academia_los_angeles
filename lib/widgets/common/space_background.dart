import 'package:flutter/material.dart';

/// Widget que proporciona un fondo espacial con estrellas animadas y gradiente personalizable
class SpaceBackground extends StatelessWidget {
  /// El contenido que se mostrará sobre el fondo espacial
  final Widget child;
  
  /// Los colores del gradiente para el fondo
  final List<Color> gradientColors;
  
  /// La cantidad de estrellas que se generarán
  final int starsCount;
  
  /// Planetas decorativos a mostrar (opcional)
  final List<SpaceDecoration> decorations;

  const SpaceBackground({
    super.key,
    required this.child,
    this.gradientColors = const [
      Color(0xFF1A237E), // Azul oscuro espacial
      Color(0xFF311B92), // Púrpura espacial
      Color(0xFF4A148C), // Morado espacial
    ],
    this.starsCount = 200,
    this.decorations = const [],
  });

  /// Constructor con colores específicos para la pantalla de login
  factory SpaceBackground.forLogin({required Widget child}) {
    return SpaceBackground(
      child: child,
      gradientColors: const [
        Color(0xFF1A237E), // Azul oscuro espacial
        Color(0xFF311B92), // Púrpura espacial
        Color(0xFF4A148C), // Morado espacial
      ],
      decorations: [
        // Planeta decorativo grande
        SpaceDecoration(
          top: 0.1,
          right: -40,
          width: 100,
          height: 100,
          colors: [
            Colors.orange.shade300,
            Colors.orange.shade700,
          ],
          icon: null,
        ),
        // Planeta pequeño decorativo
        SpaceDecoration(
          bottom: 0.15,
          left: -20,
          width: 60,
          height: 60,
          colors: [
            Colors.lightBlue.shade300,
            Colors.lightBlue.shade700,
          ],
          icon: null,
        ),
      ],
    );
  }

  /// Constructor con colores específicos para la pantalla de registro
  factory SpaceBackground.forRegister({required Widget child}) {
    return SpaceBackground(
      child: child,
      gradientColors: const [
        Color(0xFF6A1B9A), // Púrpura oscuro espacial
        Color(0xFF4527A0), // Púrpura espacial
        Color(0xFF283593), // Azul espacial
      ],
      decorations: [
        // Planeta decorativo
        SpaceDecoration(
          top: 0.15,
          left: -30,
          width: 80,
          height: 80,
          colors: [
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade900,
          ],
          icon: null,
        ),
        // Planeta pequeño decorativo
        SpaceDecoration(
          bottom: 0.3,
          right: -20,
          width: 60,
          height: 60,
          colors: [
            Colors.teal.shade300,
            Colors.teal.shade900,
          ],
          icon: null,
        ),
      ],
    );
  }

  /// Constructor con colores específicos para la pantalla de registro de profesores
  factory SpaceBackground.forTeacherRegister({required Widget child}) {
    return SpaceBackground(
      child: child,
      gradientColors: const [
        Color(0xFF8E24AA), // Púrpura más científico
        Color(0xFF7B1FA2), // Púrpura medio
        Color(0xFF6A1B9A), // Púrpura oscuro
      ],
      decorations: [
        // Planeta decorativo
        SpaceDecoration(
          top: 0.15,
          left: -30,
          width: 80,
          height: 80,
          colors: [
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade900,
          ],
          icon: null,
        ),
        // "Laboratorio" espacial decorativo
        SpaceDecoration(
          bottom: 0.3,
          right: -20,
          width: 80,
          height: 80,
          colors: [
            Colors.teal.shade300,
            Colors.teal.shade900,
          ],
          icon: Icons.science,
          iconColor: Colors.white,
          iconSize: 40,
        ),
      ],
    );
  }

  /// Constructor con colores específicos para la pantalla de unirse a un aula
  factory SpaceBackground.forJoinClassroom({required Widget child}) {
    return SpaceBackground(
      child: child,
      gradientColors: const [
        Color(0xFF1A237E), // Azul oscuro espacial
        Color(0xFF311B92), // Púrpura espacial
        Color(0xFF4A148C), // Morado espacial
      ],
      decorations: [
        // Planeta decorativo
        SpaceDecoration(
          top: 0.1,
          right: -40,
          width: 100,
          height: 100,
          colors: [
            Colors.orange.shade300,
            Colors.orange.shade700,
          ],
          icon: null,
        ),
        // Planeta pequeño decorativo
        SpaceDecoration(
          bottom: 0.15,
          left: -20,
          width: 60,
          height: 60,
          colors: [
            Colors.lightBlue.shade300,
            Colors.lightBlue.shade700,
          ],
          icon: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Estrellas parpadeantes
          ..._generateStars(starsCount, size),
          
          // Decoraciones (planetas, etc.)
          ...decorations.map((decoration) => _buildDecoration(decoration, size)),
          
          // Contenido principal
          child,
        ],
      ),
    );
  }

  /// Construye una decoración espacial (planeta, etc.)
  Widget _buildDecoration(SpaceDecoration decoration, Size screenSize) {
    return Positioned(
      top: decoration.top != null ? screenSize.height * decoration.top! : null,
      bottom: decoration.bottom != null ? screenSize.height * decoration.bottom! : null,
      left: decoration.left,
      right: decoration.right,
      child: Container(
        width: decoration.width,
        height: decoration.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: decoration.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: decoration.colors[0].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: decoration.icon != null
            ? Center(
                child: Icon(
                  decoration.icon,
                  color: decoration.iconColor ?? Colors.white,
                  size: decoration.iconSize ?? 24,
                ),
              )
            : null,
      ),
    );
  }

  /// Función para generar estrellas aleatorias
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

  /// Construye una estrella con animación de brillo
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

/// Clase que define una decoración espacial (planeta, etc.)
class SpaceDecoration {
  /// Posición superior relativa a la altura de la pantalla (0.0 a 1.0)
  final double? top;
  
  /// Posición inferior relativa a la altura de la pantalla (0.0 a 1.0)
  final double? bottom;
  
  /// Posición izquierda en píxeles (puede ser negativa para efectos fuera de pantalla)
  final double? left;
  
  /// Posición derecha en píxeles (puede ser negativa para efectos fuera de pantalla)
  final double? right;
  
  /// Ancho de la decoración en píxeles
  final double width;
  
  /// Alto de la decoración en píxeles
  final double height;
  
  /// Colores para el gradiente de la decoración
  final List<Color> colors;
  
  /// Icono opcional para mostrar dentro de la decoración
  final IconData? icon;
  
  /// Color del icono
  final Color? iconColor;
  
  /// Tamaño del icono
  final double? iconSize;

  const SpaceDecoration({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.width,
    required this.height,
    required this.colors,
    this.icon,
    this.iconColor,
    this.iconSize,
  });
}