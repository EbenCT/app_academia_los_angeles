import 'package:flutter/material.dart';

/// Utilidad para gestionar iconos de la aplicación
class AppIcons {
  /// Obtiene un icono de curso basado en el nombre
  static IconData getCourseIcon(String courseTitle) {
    final title = courseTitle.toLowerCase();
    if (title.contains('matemática')) return Icons.calculate;
    if (title.contains('ciencia')) return Icons.science;
    if (title.contains('lenguaje')) return Icons.menu_book;
    if (title.contains('historia')) return Icons.history_edu;
    if (title.contains('inglés')) return Icons.language;
    if (title.contains('arte')) return Icons.brush;
    if (title.contains('música')) return Icons.music_note;
    if (title.contains('física')) return Icons.speed;
    if (title.contains('química')) return Icons.science;
    if (title.contains('biología')) return Icons.spa;
    // Verificar opciones más específicas para subcategorías
    if (title.contains('geometría')) return Icons.straighten;
    if (title.contains('fracciones')) return Icons.pie_chart;
    if (title.contains('número')) return Icons.numbers;
    // Icono predeterminado
    return Icons.school;
  }
  
  /// Obtiene un icono de logro basado en el nombre
  static IconData getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history_edu':
        return Icons.history_edu;
      case 'menu_book':
        return Icons.menu_book;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'school':
        return Icons.school;
      case 'star':
        return Icons.star;
      default:
        return Icons.emoji_events; // Icono predeterminado
    }
  }
  
  /// Obtiene un color para un curso basado en un índice
  static Color getCourseColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
  
  /// Obtiene un color basado en la altitud
  static Color getAltitudeColor(double altitude) {
    if (altitude > 200) return Colors.purple;
    if (altitude > 0) return Colors.blue;
    if (altitude > -50) return Colors.green;
    return Colors.indigo;
  }
}