import 'package:flutter/material.dart';
import 'app_colors.dart';
/// Decoraciones centralizadas para la aplicación.
class AppDecorations {
  // Decoración para contenedores principales
  static BoxDecoration get mainCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Decoración para contenedores principales en modo oscuro
  static BoxDecoration get darkMainCard => BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Decoración para contenedores de logros
  static BoxDecoration get achievementCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
  
  // Decoración para tarjetas de curso
  static BoxDecoration get courseCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
  
  // Decoración para avatares
  static BoxDecoration get avatar => BoxDecoration(
    color: AppColors.primary.withOpacity(0.2),
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.primary, width: 2),
  );
  
  // Decoración para fondos con gradiente
  static BoxDecoration get gradientBackground => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary,
        AppColors.primary.withOpacity(0.8),
        AppColors.primary.withOpacity(0.6),
      ],
    ),
  );
  
  // Decoración para campos de entrada
  static InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      fillColor: AppColors.inputBackground,
      filled: true,
      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          prefixIcon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
    );
  }
}