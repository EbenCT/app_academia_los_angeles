import 'package:flutter/material.dart';
import '../animations/bounce_animation.dart';

/// Widget reutilizable para mostrar información estadística
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool animated;
  final bool useContainer;
  final double? width;
  final double? height;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.animated = true,
    this.useContainer = true,
    this.width = 90,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Widget content = Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: useContainer ? BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ) : null,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    
    if (animated) {
      content = BounceAnimation(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      );
    } else if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }
    
    return content;
  }
  
  /// Constructor fábrica para mostrar un elemento de progreso específico
  factory StatCard.progressItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) => StatCard(
    title: title,
    value: value,
    icon: icon,
    color: color,
    onTap: onTap,
    useContainer: true,
    animated: true,
  );
}