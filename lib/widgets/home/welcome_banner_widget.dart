import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../animations/bounce_animation.dart';
import '../common/app_card.dart';

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
    return AppCard.withGradient(
      colors: [
        Color(0xFFFFD700), // Amarillo
        Color(0xFF0066CC), // Azul
      ],
      child: _buildBannerContent(),
      
    );
  }

  Widget _buildBannerContent() {
    return Stack(
      children: [
        // Estrellas decorativas animadas
        _buildAnimatedStar(top: 15, right: 20, size: 30, delay: 0),
        _buildAnimatedStar(top: 40, left: 25, size: 20, delay: 300),
        _buildAnimatedStar(bottom: 20, right: 40, size: 25, delay: 600),
        
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
              _buildLevelBadge(),
              const SizedBox(height: 12),
              _buildWelcomeMessage(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnimatedStar({double? top, double? left, double? right, double? bottom, required double size, required int delay}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: BounceAnimation(
        infinite: true,
        delay: Duration(milliseconds: delay),
        duration: const Duration(milliseconds: 2000),
        child: Icon(
          Icons.star,
          color: Colors.yellow,
          size: size,
        ),
      ),
    );
  }
  
  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
  
  Widget _buildWelcomeMessage() {
    return Container(
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
    );
  }
}