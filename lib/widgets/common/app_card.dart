import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget reutilizable para tarjetas con estilos consistentes
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasShadow;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 20.0,
    this.hasShadow = true,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
                    (isDarkMode ? AppColors.darkSurface : Colors.white);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? bgColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null ? Border.all(
              color: borderColor!,
              width: 2,
            ) : null,
            boxShadow: hasShadow ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// Constructor fábrica para crear una tarjeta con gradiente
  factory AppCard.withGradient({
    required Widget child,
    required List<Color> colors,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20.0,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    bool hasShadow = true,
    VoidCallback? onTap,
  }) => AppCard(
    child: child,
    padding: padding,
    borderRadius: borderRadius,
    hasShadow: hasShadow,
    onTap: onTap,
    gradient: LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    ),
  );
  
  /// Constructor fábrica para una tarjeta de tema primario
  factory AppCard.primary({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20.0,
    bool hasShadow = true,
    VoidCallback? onTap,
  }) => AppCard(
    child: child,
    padding: padding,
    borderRadius: borderRadius,
    hasShadow: hasShadow,
    onTap: onTap,
    borderColor: AppColors.primary.withOpacity(0.3),
    backgroundColor: AppColors.primary.withOpacity(0.1),
  );
  
  /// Constructor fábrica para una tarjeta de tema secundario
  factory AppCard.secondary({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20.0,
    bool hasShadow = true,
    VoidCallback? onTap,
  }) => AppCard(
    child: child,
    padding: padding,
    borderRadius: borderRadius,
    hasShadow: hasShadow,
    onTap: onTap,
    borderColor: AppColors.secondary.withOpacity(0.3),
    backgroundColor: AppColors.secondary.withOpacity(0.1),
  );
}