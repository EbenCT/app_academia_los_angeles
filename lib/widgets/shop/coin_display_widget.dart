// lib/widgets/shop/coin_display_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coin_provider.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';

class CoinDisplayWidget extends StatelessWidget {
  final bool showAnimation;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const CoinDisplayWidget({
    Key? key,
    this.showAnimation = true,
    this.size = 16,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final coinAmount = coinProvider.coins.amount;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.star.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.star.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: AppColors.star,
            size: size,
          ),
          const SizedBox(width: 4),
          Text(
            coinAmount.toString(),
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppColors.star,
            ),
          ),
        ],
      ),
    );

    if (showAnimation) {
      return BounceAnimation(
        child: content,
      );
    }

    return content;
  }

  /// Factory para crear un display grande para la tienda
  factory CoinDisplayWidget.large({
    Color? backgroundColor,
    Color? textColor,
  }) => CoinDisplayWidget(
    size: 24,
    backgroundColor: backgroundColor,
    textColor: textColor,
    showAnimation: true,
  );

  /// Factory para crear un display pequeño para el header
  factory CoinDisplayWidget.small({
    Color? backgroundColor,
    Color? textColor,
  }) => CoinDisplayWidget(
    size: 14,
    backgroundColor: backgroundColor,
    textColor: textColor,
    showAnimation: false,
  );
}