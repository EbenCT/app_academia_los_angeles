// lib/widgets/game/mini_avatar_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MiniAvatarWidget extends StatelessWidget {
  final Map<String, dynamic>? avatarData;
  final double size;
  final bool isActive;
  
  const MiniAvatarWidget({
    Key? key,
    this.avatarData,
    this.size = 40,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay datos de avatar, mostrar avatar por defecto
    if (avatarData == null) {
      return _buildDefaultAvatar(context);
    }
    
    // Extraer propiedades básicas
    final gender = avatarData!['gender'] ?? 'boy';
    final skinToneIndex = avatarData!['skinToneIndex'] ?? 0;
    
    // Extraer propiedades de cabello
    final Map<String, dynamic> hairData = avatarData!['hair'] ?? {'colorIndex': 0};
    final hairColorIndex = hairData['colorIndex'] ?? 0;
    
    // Lista de colores disponibles
    final List<Color> skinTones = [
      const Color(0xFFFADCBC), // Light
      const Color(0xFFF1C27D), // Medium
      const Color(0xFFE0AC69), // Tan
      const Color(0xFFC68642), // Brown
      const Color(0xFF8D5524), // Dark
    ];
    
    final List<Color> hairColors = [
      Colors.black,
      Colors.brown,
      Colors.amber,
      Colors.red,
      const Color(0xFF8D4848), // castaño rojizo
      Colors.blueGrey,
      Colors.purple,
      Colors.pink,
    ];
    
    // Obtener colores específicos
    final Color skinColor = skinTones[skinToneIndex % skinTones.length];
    final Color hairColor = hairColors[hairColorIndex % hairColors.length];
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.secondary : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Cabeza con tono de piel
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: skinColor,
              shape: BoxShape.circle,
            ),
          ),
          
          // Cabello simplificado (solo una parte superior)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.4,
              decoration: BoxDecoration(
                color: hairColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.5),
                  topRight: Radius.circular(size * 0.5),
                ),
              ),
            ),
          ),
          
          // Ojos simplificados
          Positioned(
            top: size * 0.4,
            left: size * 0.25,
            right: size * 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.07,
                      height: size * 0.07,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.07,
                      height: size * 0.07,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Boca simplificada
          Positioned(
            bottom: size * 0.25,
            left: size * 0.3,
            right: size * 0.3,
            child: Container(
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.secondary : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.face,
        color: AppColors.primary,
        size: size * 0.7,
      ),
    );
  }
}