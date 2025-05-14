import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget reutilizable para títulos de sección
class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final IconData? icon;
  final double? iconSize;
  final VoidCallback? onTap;
  
  const SectionTitle({
    Key? key,
    required this.title,
    this.color,
    this.padding = const EdgeInsets.only(left: 8.0),
    this.style,
    this.icon,
    this.iconSize = 24.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = style?.color ?? 
                     (isDarkMode ? Colors.white : AppColors.textPrimary);
    
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: themeColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: style?.copyWith(color: textColor) ?? TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Factory para crear un título de sección con un color específico
  factory SectionTitle.withColor({
    required String title,
    required Color color,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
    IconData? icon,
    double? iconSize,
    VoidCallback? onTap,
  }) => SectionTitle(
    title: title,
    color: color,
    padding: padding,
    style: style,
    icon: icon,
    iconSize: iconSize,
    onTap: onTap,
  );
}