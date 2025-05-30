// lib/widgets/shop/active_booster_indicator.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/booster_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/bounce_animation.dart';

class ActiveBoosterIndicator extends StatelessWidget {
  final bool isFloating;
  final VoidCallback? onTap;

  const ActiveBoosterIndicator({
    Key? key,
    this.isFloating = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BoosterProvider>(
      builder: (context, boosterProvider, child) {
        if (!boosterProvider.hasActiveBooster) {
          return const SizedBox.shrink();
        }

        final booster = boosterProvider.activeBooster!;

        if (isFloating) {
          return _buildFloatingIndicator(booster, boosterProvider);
        } else {
          return _buildInlineIndicator(booster, boosterProvider);
        }
      },
    );
  }

  Widget _buildFloatingIndicator(dynamic booster, BoosterProvider provider) {
    return Positioned(
      top: 100,
      right: 20,
      child: BounceAnimation(
        infinite: true,
        duration: const Duration(seconds: 2),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animación del potenciador
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset(
                    booster.iconPath,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Multiplicadores activos
                _buildMultiplierBadges(booster),
                
                const SizedBox(height: 4),
                
                // Tiempo restante
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.getFormattedRemainingTime(),
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Barra de progreso circular
                const SizedBox(height: 4),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: booster.progressPercentage,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineIndicator(dynamic booster, BoosterProvider provider) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icono animado
              SizedBox(
                width: 50,
                height: 50,
                child: Lottie.asset(
                  booster.iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información del potenciador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'POTENCIADOR ACTIVO',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          provider.getFormattedRemainingTime(),
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      booster.name,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Multiplicadores
                    _buildMultiplierBadges(booster),
                    
                    const SizedBox(height: 8),
                    
                    // Barra de progreso
                    LinearProgressIndicator(
                      value: booster.progressPercentage,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultiplierBadges(dynamic booster) {
    List<Widget> badges = [];
    
    if (booster.xpMultiplier > 1.0) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.white, size: 12),
              const SizedBox(width: 2),
              Text(
                'x${booster.xpMultiplier.toStringAsFixed(1)}',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (booster.coinMultiplier > 1.0) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: Colors.white, size: 12),
              const SizedBox(width: 2),
              Text(
                'x${booster.coinMultiplier.toStringAsFixed(1)}',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      children: badges,
    );
  }
}