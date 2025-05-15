// lib/widgets/profile/fluttermoji_avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import '../../theme/app_colors.dart';

class FluttermojiAvatarWidget extends StatelessWidget {
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showLevel;
  final int level;
  
  const FluttermojiAvatarWidget({
    Key? key,
    this.size = 100,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 3,
    this.showLevel = false,
    this.level = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final effectiveBorderColor = borderColor ?? 
        AppColors.primary.withOpacity(0.5);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar de Fluttermoji
        showBorder 
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  ),
                ),
                child: FluttermojiCircleAvatar(
                  radius: radius,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkPrimary.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                ),
              )
            : FluttermojiCircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
              ),
        
        // Nivel (opcional)
        if (showLevel && level > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                level.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}