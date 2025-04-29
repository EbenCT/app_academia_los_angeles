// lib/widgets/lessons/lesson_card_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';

/// Widget para mostrar una tarjeta informativa en una lección
class LessonCardWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final Color? cardColor;
  final Color? titleColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final Duration? animationDelay;

  const LessonCardWidget({
    Key? key,
    required this.title,
    required this.content,
    this.cardColor,
    this.titleColor,
    this.icon,
    this.padding,
    this.animationDelay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = cardColor ?? Colors.white;
    final effectiveTitleColor = titleColor ?? AppColors.primary;
    final delay = animationDelay ?? const Duration(milliseconds: 300);

    return FadeAnimation(
      delay: delay,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            if (icon != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveTitleColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: effectiveTitleColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: effectiveTitleColor,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: effectiveTitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 16),
            
            // Contenido
            content,
          ],
        ),
      ),
    );
  }
}

/// Widget para una explicación con viñetas (bullet points)
class BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const BulletPoint({
    Key? key,
    required this.text,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para una sección con imagen y texto explicativo
class ImageExplanationWidget extends StatelessWidget {
  final String imagePath;
  final String explanation;
  final double? imageHeight;
  final Widget? fallbackWidget;
  final EdgeInsetsGeometry? padding;

  const ImageExplanationWidget({
    Key? key,
    required this.imagePath,
    required this.explanation,
    this.imageHeight = 150,
    this.fallbackWidget,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen no existe, mostrar el widget de respaldo
                return fallbackWidget ??
                    Container(
                      height: imageHeight,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined, 
                                size: 40, 
                                color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'Imagen no disponible',
                              style: TextStyle(
                                  fontFamily: 'Comic Sans MS', 
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Explicación
          Text(
            explanation,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para conceptos clave en formato destacado
class KeyConceptsWidget extends StatelessWidget {
  final List<Widget> concepts;
  final Color? backgroundColor;
  final Color? borderColor;
  final String title;

  const KeyConceptsWidget({
    Key? key,
    required this.concepts,
    required this.title,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.accent.withOpacity(0.2);
    final border = borderColor ?? AppColors.accent.withOpacity(0.5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: borderColor?.withOpacity(1.0) ?? AppColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Lista de conceptos
          ...concepts,
        ],
      ),
    );
  }
}