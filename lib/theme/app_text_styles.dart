import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto centralizados para la aplicación.
class AppTextStyles {
  // Fuente base para toda la aplicación
  static TextStyle get _baseTextStyle => GoogleFonts.comicNeue();
  
  // Tema para textos claros (Tema Light)
  static TextTheme get textTheme {
    return TextTheme(
      // Textos de cabecera
      displayLarge: _baseTextStyle.copyWith(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: AppColors.primary,
      ),
      displayMedium: _baseTextStyle.copyWith(
        fontSize: 28, 
        fontWeight: FontWeight.bold, 
        color: AppColors.primary,
      ),
      displaySmall: _baseTextStyle.copyWith(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: AppColors.primary,
      ),
      
      // Textos de título
      headlineLarge: _baseTextStyle.copyWith(
        fontSize: 22, 
        fontWeight: FontWeight.bold, 
        color: AppColors.textPrimary,
      ),
      headlineMedium: _baseTextStyle.copyWith(
        fontSize: 20, 
        fontWeight: FontWeight.w600, 
        color: AppColors.textPrimary,
      ),
      headlineSmall: _baseTextStyle.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: AppColors.textPrimary,
      ),
      
      // Textos de cuerpo
      bodyLarge: _baseTextStyle.copyWith(
        fontSize: 16, 
        color: AppColors.textPrimary,
      ),
      bodyMedium: _baseTextStyle.copyWith(
        fontSize: 14, 
        color: AppColors.textPrimary,
      ),
      bodySmall: _baseTextStyle.copyWith(
        fontSize: 12, 
        color: AppColors.textSecondary,
      ),
      
      // Otros estilos
      titleLarge: _baseTextStyle.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: AppColors.textPrimary,
      ),
      titleMedium: _baseTextStyle.copyWith(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: AppColors.textPrimary,
      ),
      titleSmall: _baseTextStyle.copyWith(
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        color: AppColors.textPrimary,
      ),
      labelLarge: _baseTextStyle.copyWith(
        fontSize: 16, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
      ),
      labelMedium: _baseTextStyle.copyWith(
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        color: AppColors.primary,
      ),
      labelSmall: _baseTextStyle.copyWith(
        fontSize: 12, 
        fontWeight: FontWeight.w600, 
        color: AppColors.textSecondary,
      ),
    );
  }
  
  // Tema para textos oscuros (Tema Dark)
  static TextTheme get darkTextTheme {
    return TextTheme(
      // Textos de cabecera
      displayLarge: _baseTextStyle.copyWith(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkPrimary,
      ),
      displayMedium: _baseTextStyle.copyWith(
        fontSize: 28, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkPrimary,
      ),
      displaySmall: _baseTextStyle.copyWith(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkPrimary,
      ),
      
      // Textos de título
      headlineLarge: _baseTextStyle.copyWith(
        fontSize: 22, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: _baseTextStyle.copyWith(
        fontSize: 20, 
        fontWeight: FontWeight.w600, 
        color: AppColors.darkTextPrimary,
      ),
      headlineSmall: _baseTextStyle.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: AppColors.darkTextPrimary,
      ),
      
      // Textos de cuerpo
      bodyLarge: _baseTextStyle.copyWith(
        fontSize: 16, 
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: _baseTextStyle.copyWith(
        fontSize: 14, 
        color: AppColors.darkTextPrimary,
      ),
      bodySmall: _baseTextStyle.copyWith(
        fontSize: 12, 
        color: AppColors.darkTextSecondary,
      ),
      
      // Otros estilos
      titleLarge: _baseTextStyle.copyWith(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: _baseTextStyle.copyWith(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: AppColors.darkTextPrimary,
      ),
      titleSmall: _baseTextStyle.copyWith(
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        color: AppColors.darkTextPrimary,
      ),
      labelLarge: _baseTextStyle.copyWith(
        fontSize: 16, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
      ),
      labelMedium: _baseTextStyle.copyWith(
        fontSize: 14, 
        fontWeight: FontWeight.w600, 
        color: AppColors.primary,
      ),
      labelSmall: _baseTextStyle.copyWith(
        fontSize: 12, 
        fontWeight: FontWeight.w600, 
        color: AppColors.darkTextSecondary,
      ),
    );
  }
  
  // Estilos específicos para componentes
  static TextStyle get buttonText => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get inputText => _baseTextStyle.copyWith(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get inputHint => _baseTextStyle.copyWith(
    fontSize: 16,
    color: AppColors.textHint,
  );
  
  static TextStyle get linkText => _baseTextStyle.copyWith(
    fontSize: 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
  
  static TextStyle get errorText => _baseTextStyle.copyWith(
    fontSize: 12,
    color: AppColors.error,
  );
}