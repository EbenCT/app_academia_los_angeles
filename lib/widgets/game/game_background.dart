// lib/widgets/game/game_background.dart (con mejoras)
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameBackground extends StatelessWidget {
  final double maxHeight;
  final double minHeight;
  final double mountainHeight;
  final int cloudDensity;
  
  const GameBackground({
    Key? key,
    required this.maxHeight,
    required this.minHeight,
    this.mountainHeight = 100, // Altura predeterminada aumentada
    this.cloudDensity = 15, // Mayor densidad de nubes
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        
        final totalRange = maxHeight - minHeight;
        final pixelsPerMeter = height / totalRange;
        
        // Calcular posición del nivel del mar (0m)
        final seaLevel = (maxHeight - 0) * pixelsPerMeter;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            // Espacio (400m a 200m) - Gradiente más intenso
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6],
                  colors: [
                    Colors.black,
                    Colors.indigo.shade900,
                  ],
                ),
              ),
            ),
            
            // Estrellas (más densas)
            _buildStars(width, height, 100), // Más estrellas
            
            // Cielo (200m a 0m) - Gradiente más brillante
            Positioned(
              top: height * 0.3,
              left: 0,
              right: 0,
              bottom: seaLevel,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.lightBlue.shade300,
                    ],
                  ),
                ),
              ),
            ),
            
            // Nubes mejoradas
            _buildClouds(width, height, seaLevel),
            
            // Nivel del mar y montañas
            Positioned(
              top: seaLevel - mountainHeight, // Montañas más altas
              left: 0,
              right: 0,
              height: mountainHeight,
              child: CustomPaint(
                painter: MountainPainter(),
                size: Size(width, mountainHeight),
              ),
            ),
            
            // Línea del nivel del mar
            Positioned(
              top: seaLevel,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            // Mar (0m a -150m) - Gradiente más intenso
            Positioned(
              top: seaLevel,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.lightBlue.shade300,
                      Colors.blue.shade900,
                    ],
                  ),
                ),
              ),
            ),
            
            // Burbujas
            _buildBubbles(width, height, seaLevel),
            
            // Marcadores de altura (mejorados para visibilidad)
            ..._buildAltitudeMarkers(height, width),
          ],
        );
      },
    );
  }

  Widget _buildStars(double width, double height, int count) {
    final random = math.Random(42); // Semilla fija para consistencia
    
    return Stack(
      children: List.generate(count, (index) {
        final size = random.nextDouble() * 2 + 1; // Tamaño entre 1 y 3
        final opacity = random.nextDouble() * 0.5 + 0.5; // Opacidad entre 0.5 y 1
        
        return Positioned(
          left: random.nextDouble() * width,
          top: random.nextDouble() * height * 0.4, // Solo en la parte superior
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClouds(double width, double height, double seaLevel) {
    final random = math.Random(42); // Semilla fija para consistencia
    final skyHeight = seaLevel - height * 0.3;
    
    return Stack(
      children: List.generate(cloudDensity, (index) {
        // Variaciones en el tamaño y posición de nubes
        final cloudWidth = random.nextInt(80) + 60.0; // Entre 60 y 140
        final cloudHeight = cloudWidth * 0.6;
        
        return Positioned(
          left: random.nextDouble() * width,
          top: height * 0.3 + random.nextDouble() * skyHeight * 0.8,
          child: Opacity(
            opacity: random.nextDouble() * 0.4 + 0.6, // Entre 0.6 y 1.0
            child: Container(
              width: cloudWidth,
              height: cloudHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cloudHeight / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBubbles(double width, double height, double seaLevel) {
    final random = math.Random(42); // Semilla fija para consistencia
    final waterHeight = height - seaLevel;
    
    return Stack(
      children: List.generate(40, (index) {
        // Variaciones en el tamaño y posición de burbujas
        final bubbleSize = random.nextDouble() * 5 + 3; // Entre 3 y 8
        
        return Positioned(
          left: random.nextDouble() * width,
          top: seaLevel + random.nextDouble() * waterHeight,
          child: Container(
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(random.nextDouble() * 0.3 + 0.2),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildAltitudeMarkers(double height, double width) {
    final altitudeMarkers = <Widget>[];
    final totalRange = maxHeight - minHeight;
    final pixelsPerMeter = height / totalRange;
    
    // Alturas a marcar
    final markers = [400, 300, 200, 100, 50, 0, -25, -50, -100, -150];
    
    for (var altitude in markers) {
      // Calcular la posición vertical
      final position = (maxHeight - altitude) * pixelsPerMeter;
      
      altitudeMarkers.add(
        Positioned(
          top: position - 10, // Ajustar para centrar el texto
          left: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Marcador con fondo para mejor visibilidad
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$altitude m',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 5),
              // Línea punteada en lugar de línea continua
              Container(
                width: width * 0.7, // Línea más corta para no obstruir
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return altitudeMarkers;
  }
}

// Pintor personalizado para las montañas (más pronunciadas)
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.35, size.height * 0.1); // Pico más alto
    path.lineTo(size.width * 0.55, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width * 0.85, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Segunda montaña con un tono diferente
    final paint2 = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height);
    path2.lineTo(size.width * 0.2, size.height * 0.4);
    path2.lineTo(size.width * 0.3, size.height * 0.6);
    path2.lineTo(size.width * 0.5, size.height * 0.2);
    path2.lineTo(size.width * 0.65, size.height * 0.5);
    path2.lineTo(size.width * 0.8, size.height * 0.3);
    path2.lineTo(size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
    
    // Tercer capa para más detalle
    final paint3 = Paint()
      ..color = Colors.brown.shade500
      ..style = PaintingStyle.fill;
      
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.75);
    path3.lineTo(size.width * 0.25, size.height * 0.65);
    path3.lineTo(size.width * 0.4, size.height * 0.8);
    path3.lineTo(size.width * 0.6, size.height * 0.6);
    path3.lineTo(size.width * 0.75, size.height * 0.75);
    path3.lineTo(size.width, size.height * 0.7);
    path3.lineTo(size.width, size.height);
    path3.close();
    
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}