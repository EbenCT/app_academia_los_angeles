// lib/screens/game/game_results_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/space_background.dart';

class GameResultsScreen extends StatelessWidget {
  final int score;
  final bool victory;
  final VoidCallback onPlayAgain;
  
  const GameResultsScreen({
    Key? key,
    required this.score,
    required this.victory,
    required this.onPlayAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Fondo espacial
          SpaceBackground(
            gradientColors: victory 
                ? [Colors.indigo.shade900, Colors.purple.shade700, Colors.blue.shade700]
                : [Colors.red.shade900, Colors.brown.shade700, Colors.orange.shade900],
            child: Container(),
          ),
          
          // Contenido principal
          SafeArea(
            child: Center(
              child: FadeAnimation(
                delay: Duration(milliseconds: 300),
                child: Container(
                  width: size.width * 0.85,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? AppColors.darkSurface.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            victory ? '🚀' : '💥 ',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                      // Título
                      Text(
                        victory ? '¡MISIÓN CUMPLIDA!' : 'MISIÓN FALLIDA',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: victory ? AppColors.success : AppColors.error,
                        ),
                        textAlign: TextAlign.center, 
                      ),
                                                Text(
                            victory ? '🚀' : ' 💥',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Animación
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Lottie.asset(
                          // lib/screens/game/game_results_screen.dart (continuación)
                          victory 
                              ? 'assets/animations/astrosuccess.json'
                              : 'assets/animations/astrofailure.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Puntuación
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: AppColors.star,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PUNTUACIÓN FINAL',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                Text(
                                  '$score puntos',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.star,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Mensaje educativo sobre números enteros
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '¿Sabías que?',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Los números enteros incluyen valores positivos, negativos y el cero. Nos ayudan a representar altitudes sobre y bajo el nivel del mar.',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Jugar',
                              onPressed: onPlayAgain,
                              icon: Icons.replay,
                              backgroundColor: AppColors.success,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Volver',
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              icon: Icons.home,
                              backgroundColor: AppColors.secondary,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}