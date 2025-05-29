// lib/widgets/pet/floating_pet_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/shop_item_model.dart';

class FloatingPetWidget extends StatefulWidget {
  final ShopItemModel pet;
  final VoidCallback? onTap;

  const FloatingPetWidget({
    Key? key,
    required this.pet,
    this.onTap,
  }) : super(key: key);

  @override
  State<FloatingPetWidget> createState() => _FloatingPetWidgetState();
}

class _FloatingPetWidgetState extends State<FloatingPetWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _bounceController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de flotación suave
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de rebote al tocar
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animación de flotación
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120, // Por encima del bottom navigation
      right: 20,
      child: GestureDetector(
        onTap: () {
          _bounceController.forward().then((_) {
            _bounceController.reverse();
          });
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatingAnimation, _bounceAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.pet.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.pet.colors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      width: 80,
                      height: 80,
                      child: widget.pet.animationPath != null
                          ? Transform.scale(
                              scale: 1.5, // Escalamos la animación para que llene mejor el círculo
                              child: Lottie.asset(
                                widget.pet.animationPath!,
                                fit: BoxFit.cover, // Cambiamos a cover para llenar todo el espacio
                                repeat: true,
                              ),
                            )
                          : Icon(
                              widget.pet.icon,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget para mostrar información de la mascota cuando se toca
class PetInfoDialog extends StatelessWidget {
  final ShopItemModel pet;

  const PetInfoDialog({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: pet.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animación de la mascota
            SizedBox(
              width: 100,
              height: 100,
              child: pet.animationPath != null
                  ? Lottie.asset(
                      pet.animationPath!,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      pet.icon,
                      color: Colors.white,
                      size: 60,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Nombre de la mascota
            Text(
              pet.name,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Descripción
            Text(
              pet.description,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Botón para cerrar
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: pet.colors.first,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                '¡Genial!',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}