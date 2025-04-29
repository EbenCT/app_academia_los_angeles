// lib/screens/game/number_line_painter.dart
import 'package:flutter/material.dart';

class NumberLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    // Dibujar la línea principal
    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(size.width, size.height / 2);
    canvas.drawLine(startPoint, endPoint, paint);
    
    // Dibujar marcas para cada número
    final numberCount = 11; // De -5 a +5
    final spacing = size.width / (numberCount - 1);
    
    for (int i = 0; i < numberCount; i++) {
      final x = i * spacing;
      final number = i - 5; // Para que vaya de -5 a +5
      
      // Dibujar la marca en la línea
      final topPoint = Offset(x, size.height / 2 - 10);
      final bottomPoint = Offset(x, size.height / 2 + 10);
      canvas.drawLine(topPoint, bottomPoint, paint);
      
      // Preparar el texto (número)
      final String numberText = number.toString();
      textPainter.text = TextSpan(
        text: numberText,
        style: TextStyle(
          color: number < 0 ? Colors.red : (number > 0 ? Colors.blue : Colors.purple),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
      );
      
      // Posicionar y dibujar el número
      textPainter.layout();
      final textX = x - textPainter.width / 2;
      final textY = size.height / 2 + 15;
      textPainter.paint(canvas, Offset(textX, textY));
      
      // Si es cero, marcarlo especialmente
      if (number == 0) {
        final zeroPaint = Paint()
          ..color = Colors.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        canvas.drawCircle(
          Offset(x, size.height / 2),
          8,
          zeroPaint,
        );
      }
    }
    
    // Añadir flechas en los extremos
    final arrowPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    
    // Flecha izquierda
    final leftArrowPath = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(15, size.height / 2 - 8)
      ..lineTo(15, size.height / 2 + 8)
      ..close();
    
    // Flecha derecha
    final rightArrowPath = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(size.width - 15, size.height / 2 - 8)
      ..lineTo(size.width - 15, size.height / 2 + 8)
      ..close();
    
    canvas.drawPath(leftArrowPath, arrowPaint);
    canvas.drawPath(rightArrowPath, arrowPaint);
    
    // Añadir etiquetas para números negativos y positivos
    textPainter.text = TextSpan(
      text: 'Números negativos',
      style: TextStyle(
        color: Colors.red,
        fontSize: 12,
        fontFamily: 'Comic Sans MS',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.2 - textPainter.width / 2, 10));
    
    textPainter.text = TextSpan(
      text: 'Números positivos',
      style: TextStyle(
        color: Colors.blue,
        fontSize: 12,
        fontFamily: 'Comic Sans MS',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.8 - textPainter.width / 2, 10));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AltitudePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    
    // Pintar cielo
    final skyPaint = Paint()
      ..color = Colors.lightBlue.shade100
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, centerY),
      skyPaint,
    );
    
    // Pintar mar
    final seaPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, centerY, width, centerY),
      seaPaint,
    );
    
    // Línea de nivel del mar
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, centerY),
      Offset(width, centerY),
      linePaint,
    );
    
    // Pintar montaña
    final mountainPath = Path()
      ..moveTo(width * 0.1, centerY)
      ..lineTo(width * 0.3, centerY - height * 0.3)
      ..lineTo(width * 0.5, centerY - height * 0.1)
      ..lineTo(width * 0.7, centerY - height * 0.4)
      ..lineTo(width * 0.9, centerY)
      ..close();
    
    final mountainPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(mountainPath, mountainPaint);
    
    // Pintar submarino o pez
    final fishPath = Path()
      ..moveTo(width * 0.3, centerY + height * 0.3)
      ..quadraticBezierTo(width * 0.4, centerY + height * 0.2, width * 0.5, centerY + height * 0.3)
      ..quadraticBezierTo(width * 0.4, centerY + height * 0.4, width * 0.3, centerY + height * 0.3)
      ..close();
    
    final fishPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(fishPath, fishPaint);
    
    // Añadir ojo al pez
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(width * 0.35, centerY + height * 0.3),
      3,
      eyePaint,
    );
    
    // Pintar avión
    final planePath = Path()
      ..moveTo(width * 0.6, centerY - height * 0.2)
      ..lineTo(width * 0.7, centerY - height * 0.2)
      ..lineTo(width * 0.65, centerY - height * 0.15)
      ..close();
    
    final planePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(planePath, planePaint);
    
    // Añadir etiquetas de altura
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    // Altura montaña
    textPainter.text = TextSpan(
      text: '+400m',
      style: TextStyle(
        color: Colors.green.shade900,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS',
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(width * 0.7, centerY - height * 0.45));
    
    // Nivel del mar
    textPainter.text = TextSpan(
      text: '0m (nivel del mar)',
      style: TextStyle(
        color: Colors.blue.shade800,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS',
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, centerY - 15));
    
    // Profundidad
    textPainter.text = TextSpan(
      text: '-100m',
      style: TextStyle(
        color: Colors.yellow.shade800,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS',
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(width * 0.3, centerY + height * 0.35));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}