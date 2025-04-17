import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Indicador de carga animado personalizado
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final bool useAstronaut;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 100,
    this.useAstronaut = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useAstronaut)
            Lottie.asset(
              AssetPaths.astronautAnimation,
              width: size,
              height: size,
              fit: BoxFit.contain,
              animate: true,
            )
          else
            SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}