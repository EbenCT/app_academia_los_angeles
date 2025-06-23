// lib/widgets/terms_checkbox_widget.dart
import 'package:flutter/material.dart';
import '../../screens/terms_conditions_screen.dart';
import '../../theme/app_colors.dart';

class TermsCheckboxWidget extends StatelessWidget {
  final bool acceptTerms;
  final ValueChanged<bool> onChanged;
  final String message;

  const TermsCheckboxWidget({
    super.key,
    required this.acceptTerms,
    required this.onChanged,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checkbox con mensaje principal
        IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: acceptTerms,
                onChanged: (value) => onChanged(value ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.primary,
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onChanged(!acceptTerms),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0), // Para alinear con el checkbox
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Enlace para ver términos
        Padding(
          padding: const EdgeInsets.only(left: 48), // Alineado con el texto del checkbox
          child: GestureDetector(
            onTap: () => _showTermsConditions(context),
            child: Text(
              'Ver términos y condiciones',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 12,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsConditionsScreen(),
      ),
    );
  }
}