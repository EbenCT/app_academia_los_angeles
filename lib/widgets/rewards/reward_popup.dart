// lib/widgets/rewards/reward_popup.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_colors.dart';

class RewardPopup extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int xpEarned;
  final int coinsEarned;
  final bool leveledUp;
  final int newLevel;
  final IconData icon;

  const RewardPopup({
    Key? key,
    required this.title,
    this.subtitle,
    required this.xpEarned,
    required this.coinsEarned,
    required this.leveledUp,
    required this.newLevel,
    required this.icon,
  }) : super(key: key);

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    // Iniciar animaciones
    _scaleController.forward();
    _slideController.forward();
    
    if (widget.leveledUp) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semitransparente
        Container(
          color: Colors.black54,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.leveledUp
                            ? [AppColors.star, AppColors.secondary]
                            : [AppColors.primary, AppColors.accent],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildContent(),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Confeti para subida de nivel
        if (widget.leveledUp)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icono principal
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Subida de nivel (si aplica)
          if (widget.leveledUp) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.star.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.star),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: AppColors.star,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¡SUBISTE AL NIVEL ${widget.newLevel}!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.star,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Recompensas
          Row(
            children: [
              // XP ganada
              Expanded(
                child: _buildRewardItem(
                  icon: Icons.star,
                  color: AppColors.primary,
                  label: 'XP',
                  value: '+${widget.xpEarned}',
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Monedas ganadas
              Expanded(
                child: _buildRewardItem(
                  icon: Icons.monetization_on,
                  color: AppColors.star,
                  label: 'Monedas',
                  value: '+${widget.coinsEarned}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: widget.leveledUp ? AppColors.star : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            '¡Continuar!',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}