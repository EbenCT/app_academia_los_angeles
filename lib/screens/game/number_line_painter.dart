// lib/screens/game/number_line_painter.dart
import 'package:flutter/material.dart';

/// Clase optimizada para pintar la recta numérica con ajuste de escala 
/// para evitar desbordamiento en pantallas pequeñas
class NumberLinePainter extends CustomPainter {
  final double textScaleFactor;

  NumberLinePainter({this.textScaleFactor = 1.0});

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

    // Determinar cuántos números mostrar según el ancho
    final numberCount = size.width < 300 ? 7 : 9; // Reducido para pantallas pequeñas
    final spacing = size.width / (numberCount - 1);

    for (int i = 0; i < numberCount; i++) {
      final x = i * spacing;
      final offset = (numberCount - 1) ~/ 2;
      final number = i - offset; // Para que vaya de -3 a +3 o -4 a +4

      // Dibujar la marca en la línea
      final topPoint = Offset(x, size.height / 2 - 10);
      final bottomPoint = Offset(x, size.height / 2 + 10);
      canvas.drawLine(topPoint, bottomPoint, paint);

      // Determinar el color basado en el valor
      Color numberColor;
      if (number < 0) {
        numberColor = Colors.red;
      } else if (number > 0) {
        numberColor = Colors.blue;
      } else {
        numberColor = Colors.purple;
      }

      // Preparar el texto (número)
      final String numberText = number.toString();
      textPainter.text = TextSpan(
        text: numberText,
        style: TextStyle(
          color: numberColor,
          fontSize: 14 * textScaleFactor, // Reducido para evitar desbordamiento
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
      );

      // Posicionar y dibujar el número
      textPainter.layout(minWidth: 0, maxWidth: size.width);
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
          6,
          zeroPaint,
        );
      }
    }

    // Añadir flechas en los extremos para indicar continuidad
    final arrowPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // Flecha izquierda
    final leftArrowPath = Path()
      ..moveTo(5, size.height / 2)
      ..lineTo(15, size.height / 2 - 6)
      ..lineTo(15, size.height / 2 + 6)
      ..close();

    // Flecha derecha
    final rightArrowPath = Path()
      ..moveTo(size.width - 5, size.height / 2)
      ..lineTo(size.width - 15, size.height / 2 - 6)
      ..lineTo(size.width - 15, size.height / 2 + 6)
      ..close();

    canvas.drawPath(leftArrowPath, arrowPaint);
    canvas.drawPath(rightArrowPath, arrowPaint);

    // Las etiquetas de "Números negativos" y "Números positivos" ahora son más pequeñas
    // para evitar desbordamiento en pantallas pequeñas
    if (size.width >= 280) { // Solo mostrar las etiquetas en pantallas suficientemente anchas
      textPainter.text = TextSpan(
        text: 'Negativos',
        style: TextStyle(
          color: Colors.red,
          fontSize: 10 * textScaleFactor,
          fontFamily: 'Comic Sans MS',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.2 - textPainter.width / 2, 5));

      textPainter.text = TextSpan(
        text: 'Positivos',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 10 * textScaleFactor,
          fontFamily: 'Comic Sans MS',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.8 - textPainter.width / 2, 5));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Clase simplificada para dibujar montañas
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.35, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Segunda capa de montañas con un tono diferente
    final paint2 = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.8);
    path2.lineTo(size.width * 0.25, size.height * 0.5);
    path2.lineTo(size.width * 0.4, size.height * 0.7);
    path2.lineTo(size.width * 0.6, size.height * 0.4);
    path2.lineTo(size.width * 0.75, size.height * 0.6);
    path2.lineTo(size.width, size.height * 0.5);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Añadir detalles de nieve en las cimas
    final paintSnow = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Nieve en la primera montaña
    final snowPath1 = Path();
    snowPath1.moveTo(size.width * 0.18, size.height * 0.22);
    snowPath1.lineTo(size.width * 0.2, size.height * 0.2);
    snowPath1.lineTo(size.width * 0.22, size.height * 0.22);
    snowPath1.close();
    canvas.drawPath(snowPath1, paintSnow);

    // Nieve en la montaña central
    final snowPath2 = Path();
    snowPath2.moveTo(size.width * 0.48, size.height * 0.12);
    snowPath2.lineTo(size.width * 0.5, size.height * 0.1);
    snowPath2.lineTo(size.width * 0.52, size.height * 0.12);
    snowPath2.close();
    canvas.drawPath(snowPath2, paintSnow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}