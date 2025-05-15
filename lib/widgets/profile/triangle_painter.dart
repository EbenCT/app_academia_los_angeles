// lib/widgets/profile/triangle_painter.dart
import 'package:flutter/material.dart';

/// Clase auxiliar para pintar un triángulo (nariz)
class TrianglePainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  
  TrianglePainter({required this.color, required this.strokeColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}