// lib/widgets/game/game_background.dart
import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  final double maxHeight;
  final double minHeight;
  
  const GameBackground({
    Key? key,
    required this.maxHeight,
    required this.minHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        
        return Stack(
          children: [
            // Espacio (400m a 200m)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.indigo.shade900,
                    ],
                  ),
                ),
                child: _buildStars(),
              ),
            ),
            
            // Cielo (200m a 0m)
            Positioned(
              top: height * 0.3,
              left: 0,
              right: 0,
              height: height * 0.3,
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
                child: _buildClouds(),
              ),
            ),
            
            // Superficie y montañas (0m)
            Positioned(
              top: height * 0.6 - 20,
              left: 0,
              right: 0,
              height: 40,
              child: Stack(
                children: [
                  // Línea del nivel del mar
                  Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  
                  // Montañas en el lado izquierdo
                  Positioned(
                    left: 0,
                    bottom: 0,
                    width: width * 0.6,
                    height: 30,
                    child: CustomPaint(
                      painter: MountainPainter(),
                      size: Size(width * 0.6, 30),
                    ),
                  ),
                ],
              ),
            ),
            
            // Mar (0m a -150m)
            Positioned(
              top: height * 0.6,
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
                child: _buildBubbles(),
              ),
            ),
            
            // Marcadores de altura
            ..._buildAltitudeMarkers(height, width),
          ],
        );
      },
    );
  }

  Widget _buildStars() {
    // Generamos estrellas aleatorias
    return Stack(
      children: List.generate(50, (index) {
        return Positioned(
          left: (index * 7.3) % 400,
          top: (index * 11.7) % 300,
          child: Container(
            width: (index % 3) + 1,
            height: (index % 3) + 1,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClouds() {
    // Nubes simples
    return Stack(
      children: List.generate(5, (index) {
        return Positioned(
          left: (index * 73) % 320,
          top: (index * 27) % 150,
          child: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBubbles() {
    // Burbujas en el agua
    return Stack(
      children: List.generate(20, (index) {
        return Positioned(
          left: (index * 19.3) % 400,
          top: (index * 23.7) % 400,
          child: Container(
            width: (index % 5) + 3,
            height: (index % 5) + 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
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
            children: [
              Text(
                '$altitude m',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Container(
                width: width - 80,
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    }
    
    return altitudeMarkers;
  }
}

// Pintor personalizado para las montañas
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Segunda montaña con un tono diferente
    final paint2 = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height);
    path2.lineTo(size.width * 0.3, size.height * 0.3);
    path2.lineTo(size.width * 0.6, size.height * 0.8);
    path2.lineTo(size.width * 0.8, size.height * 0.3);
    path2.lineTo(size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}