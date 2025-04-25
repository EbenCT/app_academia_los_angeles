// lib/widgets/home/welcome_banner_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';

class WelcomeBannerWidget extends StatelessWidget {
  final String username;
  final int level;

  const WelcomeBannerWidget({
    super.key,
    required this.username,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // Amarillo
            Color(0xFF0066CC), // Azul
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Estrellas decorativas animadas
          Positioned(
            top: 15,
            right: 20,
            child: BounceAnimation(
              infinite: true,
              duration: const Duration(milliseconds: 2000),
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 25,
            child: BounceAnimation(
              infinite: true,
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 2000),
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 40,
            child: BounceAnimation(
              infinite: true,
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 2000),
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 25,
              ),
            ),
          ),
          
          // Astronauta animado
          Positioned(
            right: 10,
            bottom: 5,
            width: 120,
            height: 120,
            child: Lottie.asset(
              AssetPaths.astronautAnimation,
              fit: BoxFit.contain,
            ),
          ),
          
          // Texto de bienvenida
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡Bienvenido astronauta!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Nivel $level',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '¡Continúa tu misión espacial!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366), // Azul oscuro
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