import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final int level;
  final bool showLevel;
  final double size;
  final VoidCallback? onTap;
  final bool animateBounce;
  final Map<String, dynamic>? avatarData;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.username,
    required this.level,
    this.showLevel = true,
    this.size = 80,
    this.onTap,
    this.animateBounce = false,
    this.avatarData,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = _buildAvatar(context);
    
    if (animateBounce) {
      avatar = BounceAnimation(
        child: avatar,
        infinite: true,
        duration: const Duration(milliseconds: 2000),
      );
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          if (showLevel) _buildLevelBadge(),
          const SizedBox(height: 4),
          _buildUsername(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = _getAvatarColor();
    
    if (avatarData != null) {
      // Si hay datos de avatar personalizados, los usamos
      return _buildCustomAvatar(context, avatarColor);
    }
    
    return Stack(
      children: [
        // Avatar base
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: avatarUrl == null ? avatarColor.withOpacity(0.2) : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: avatarColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: avatarColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildInitials(),
                  )
                : _buildInitials(),
          ),
        ),
        
        // Indicador de nivel
        _buildLevelIndicator(isDarkMode, avatarColor),
        
        // Insignia para nivel avanzado
        if (level >= 5) _buildAdvancedBadge(isDarkMode),
      ],
    );
  }
  
  Widget _buildCustomAvatar(BuildContext context, Color avatarColor) {
    final gender = avatarData!['gender'] ?? 'boy';
    final skinToneIndex = avatarData!['skinToneIndex'] ?? 0;
    final hairStyleIndex = avatarData!['hairStyleIndex'] ?? 0;
    final hairColorIndex = avatarData!['hairColorIndex'] ?? 0;
    final outfitIndex = avatarData!['outfitIndex'] ?? 0;
    final accessoryIndex = avatarData!['accessoryIndex'] ?? 0;
    
    // Lista de colores de piel disponibles
    final List<Color> skinTones = [
      const Color(0xFFFADCBC), // Light
      const Color(0xFFF1C27D), // Medium
      const Color(0xFFE0AC69), // Tan
      const Color(0xFFC68642), // Brown
      const Color(0xFF8D5524), // Dark
    ];
    
    // Lista de colores de cabello disponibles
    final List<Color> hairColors = [
      Colors.black,
      Colors.brown,
      Colors.amberAccent,
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    
    // Colores para la ropa basados en el índice
    final List<Color> outfitColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.orange,
    ];
    
    // Obtener el color de piel según el índice
    final skinTone = skinToneIndex < skinTones.length 
        ? skinTones[skinToneIndex]
        : skinTones[0];
    
    // Obtener el color del cabello según el índice
    final hairColor = hairColorIndex < hairColors.length
        ? hairColors[hairColorIndex]
        : hairColors[0];
    
    // Obtener el color de la ropa según el índice
    final outfitColor = outfitIndex < outfitColors.length
        ? outfitColors[outfitIndex]
        : outfitColors[0];
    
    return Stack(
      children: [
        // Avatar base con color de piel seleccionado
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: skinTone,
            shape: BoxShape.circle,
            border: Border.all(
              color: avatarColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: avatarColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              gender == 'boy' ? Icons.face : Icons.face_3,
              color: avatarColor,
              size: size * 0.6,
            ),
          ),
        ),
        
        // Representación del "cabello" usando un overlay
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size * 0.85,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: hairColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.4),
                  topRight: Radius.circular(size * 0.4),
                ),
              ),
            ),
          ),
        ),
        
        // Representación de la "ropa" usando un overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: size * 0.35,
            decoration: BoxDecoration(
              color: outfitColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.5),
                bottomRight: Radius.circular(size * 0.5),
              ),
            ),
          ),
        ),
        
        // Accesorios (por ejemplo, gafas)
        if (accessoryIndex == 1) // Gafas
          Positioned(
            top: size * 0.35,
            left: size * 0.2,
            child: Container(
              width: size * 0.6,
              height: size * 0.2,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
        
        // Casco espacial
        if (accessoryIndex == 4)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
            ),
          ),
          
        // Etiqueta de nivel
        _buildLevelIndicator(Theme.of(context).brightness == Brightness.dark, avatarColor),
      ],
    );
  }

  Widget _buildInitials() {
    // Obtener las iniciales del nombre de usuario
    final initials = username.isNotEmpty
        ? username.split(' ').map((word) => word.isNotEmpty ? word[0] : '').join('').toUpperCase()
        : '?';
    
    return Center(
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
  
  Widget _buildLevelIndicator(bool isDarkMode, Color avatarColor) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: size * 0.35,
        height: size * 0.35,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: avatarColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: size * 0.18,
              fontWeight: FontWeight.bold,
              color: avatarColor,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdvancedBadge(bool isDarkMode) {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: size * 0.35,
        height: size * 0.35,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.star,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.rocket_launch,
            color: AppColors.star,
            size: size * 0.18,
          ),
        ),
      ),
    );
  }
  
  Widget _buildLevelBadge() {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Nivel $level',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: size * 0.15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildUsername(BuildContext context) {
    return Text(
      username,
      style: TextStyle(
        fontFamily: 'Comic Sans MS',
        fontSize: size * 0.18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Color _getAvatarColor() {
    // Generar un color aleatorio pero consistente basado en el nombre de usuario
    final int hashCode = username.hashCode;
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];
    return colorOptions[hashCode % colorOptions.length];
  }
}