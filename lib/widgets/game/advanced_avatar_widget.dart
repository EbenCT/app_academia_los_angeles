// lib/widgets/game/advanced_avatar_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdvancedAvatarWidget extends StatelessWidget {
  final String username;
  final int level;
  final double size;
  final bool showLevel;
  final Map<String, dynamic>? avatarData;
  
  const AdvancedAvatarWidget({
    Key? key,
    required this.username,
    required this.level,
    this.size = 100,
    this.showLevel = true,
    this.avatarData,
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
    final eyesIndex = avatarData!['eyesIndex'] ?? 0;
    final noseIndex = avatarData!['noseIndex'] ?? 0; 
    final mouthIndex = avatarData!['mouthIndex'] ?? 0;
    
    // Extraer propiedades de cabello
    final Map<String, dynamic> hairData = avatarData!['hair'] ?? {'styleIndex': 0, 'colorIndex': 0};
    final hairStyleIndex = hairData['styleIndex'] ?? 0;
    final hairColorIndex = hairData['colorIndex'] ?? 0;
    
    // Extraer propiedades de ropa
    final Map<String, dynamic> outfitData = avatarData!['outfit'] ?? {'topIndex': 0, 'bottomIndex': 0, 'shoesIndex': 0};
    final topIndex = outfitData['topIndex'] ?? 0;
    final bottomIndex = outfitData['bottomIndex'] ?? 0;
    final shoesIndex = outfitData['shoesIndex'] ?? 0;
    
    // Extraer propiedades de accesorios
    final Map<String, dynamic> accessoriesData = avatarData!['accessories'] ?? {'hasGlasses': false, 'hasHat': false, 'hasBackpack': false};
    final hasGlasses = accessoriesData['hasGlasses'] ?? false;
    final hasHat = accessoriesData['hasHat'] ?? false;
    final hasBackpack = accessoriesData['hasBackpack'] ?? false;
    
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
    
    // Colores para camisetas
    final List<Color> topColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
    // Colores para pantalones
    final List<Color> bottomColors = [
      Colors.blue.shade900,
      Colors.indigo.shade800,
      Colors.brown.shade800,
      Colors.green.shade800,
      Colors.purple.shade800,
    ];
    
    // Colores para zapatos
    final List<Color> shoesColors = [
      Colors.black,
      Colors.brown.shade900,
      Colors.blue.shade900,
      Colors.grey.shade800,
    ];
 final List<Color> accessoryColors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.blue,
    ];
    
    // Obtener colores específicos
    final Color skinColor = skinTones[skinToneIndex % skinTones.length];
    final Color hairColor = hairColors[hairColorIndex % hairColors.length];
    final Color topColor = topColors[topIndex % topColors.length];
    final Color bottomColor = bottomColors[bottomIndex % bottomColors.length];
    final Color shoesColor = shoesColors[shoesIndex % shoesColors.length];
    final Color accessoryColor = accessoryColors[topIndex % accessoryColors.length]; // Usar topIndex como variación
    
    // Construir avatar personalizado
    return Stack(
      alignment: Alignment.center,
      children: [
        // Contenedor principal del avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkPrimary.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Center(
              child: _buildAvatarFigure(
                gender: gender,
                skinColor: skinColor,
                hairColor: hairColor,
                topColor: topColor,
                bottomColor: bottomColor,
                shoesColor: shoesColor,
                accessoryColor: accessoryColor,
                eyesIndex: eyesIndex,
                noseIndex: noseIndex,
                mouthIndex: mouthIndex,
                hairStyleIndex: hairStyleIndex,
                topIndex: topIndex,
                bottomIndex: bottomIndex,
                shoesIndex: shoesIndex,
                hasGlasses: hasGlasses,
                hasHat: hasHat,
                hasBackpack: hasBackpack,
              ),
            ),
          ),
        ),
        
        // Nivel (opcional)
        if (showLevel)
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
  
  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkPrimary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.face,
          color: AppColors.primary,
          size: size * 0.6,
        ),
      ),
    );
  }
  
  Widget _buildAvatarFigure({
    required String gender,
    required Color skinColor,
    required Color hairColor,
    required Color topColor,
    required Color bottomColor,
    required Color shoesColor,
    required Color accessoryColor,
    required int eyesIndex,
    required int noseIndex,
    required int mouthIndex,
    required int hairStyleIndex,
    required int topIndex,
    required int bottomIndex,
    required int shoesIndex,
    required bool hasGlasses,
    required bool hasHat,
    required bool hasBackpack,
  }) {
    // Este componente simplifica la versión completa para adaptarse a un círculo
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cabeza con rasgos faciales
          Stack(
            alignment: Alignment.center,
            children: [
              // Forma básica de la cabeza
              Container(
                width: size * 0.6,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: skinColor,
                  borderRadius: BorderRadius.circular(size * 0.3),
                ),
              ),
              
              // Cabello (simplificado)
              Positioned(
                top: -(size * 0.05),
                child: Container(
                  width: size * 0.65,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),
              
              // Ojos (simplificados)
              Positioned(
                top: size * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size * 0.1,
                      height: size * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: size * 0.05,
                          height: size * 0.05,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size * 0.1),
                    Container(
                      width: size * 0.1,
                      height: size * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: size * 0.05,
                          height: size * 0.05,
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
              
              // Boca (simplificada)
              Positioned(
                top: size * 0.4,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.08,
                  decoration: BoxDecoration(
                    color: mouthIndex == 1 ? Colors.red.withOpacity(0.6) : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: Colors.red.shade300,
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              // Gafas si están habilitadas
              if (hasGlasses)
                Positioned(
                  top: size * 0.25,
                  child: Container(
                    width: size * 0.5,
                    height: size * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size * 0.15,
                          height: size * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: size * 0.07,
                          height: 2,
                          color: Colors.black,
                        ),
                        Container(
                          width: size * 0.15,
                          height: size * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Sombrero si está habilitado
              if (hasHat)
                Positioned(
                  top: -(size * 0.15),
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: accessoryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: size * 0.7,
                          height: size * 0.07,
                          decoration: BoxDecoration(
                            color: accessoryColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Cuerpo con ropa (simplificado para avatar de círculo)
          if (size > 70) // Solo mostrar cuerpo si el avatar es lo suficientemente grande
            Container(
              width: size * 0.5,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: topColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Detalles según el tipo de camiseta
                  if (topIndex == 3) // Uniforme
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size * 0.07,
                            height: size * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: size * 0.07),
                          Container(
                            width: size * 0.07,
                            height: size * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Mochila si está habilitada
                  if (hasBackpack) 
                    Positioned(
                      right: -(size * 0.1),
                      top: size * 0.05,
                      child: Container(
                        width: size * 0.15,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          color: accessoryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
