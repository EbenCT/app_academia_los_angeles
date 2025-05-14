import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget reutilizable para botones de opciones con feedback visual
class OptionButton extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final VoidCallback? onSelected;
  final double? width;
  final double? height;
  final bool isCircular;
  final Color? color;
  
  const OptionButton({
    Key? key,
    required this.text,
    required this.isCorrect,
    this.onSelected,
    this.width,
    this.height = 50,
    this.isCircular = false,
    this.color,
  }) : super(key: key);

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  bool _isSelected = false;
  bool _showFeedback = false;
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
          _showFeedback = _isSelected;
        });
        
        if (widget.onSelected != null) {
          widget.onSelected!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _getBackgroundColor(color),
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(10),
          border: Border.all(
            color: _getBorderColor(color),
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: _isSelected ? [
            BoxShadow(
              color: _showFeedback
                  ? (widget.isCorrect ? AppColors.success : AppColors.error).withOpacity(0.3)
                  : color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getTextColor(color),
              ),
              textAlign: TextAlign.center,
            ),
            if (_showFeedback)
              Positioned(
                top: 5,
                right: 5,
                child: Icon(
                  widget.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: widget.isCorrect ? AppColors.success : AppColors.error,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getBackgroundColor(Color baseColor) {
    if (!_isSelected) return Colors.white;
    if (_showFeedback) {
      return widget.isCorrect 
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
    }
    return baseColor.withOpacity(0.1);
  }
  
  Color _getBorderColor(Color baseColor) {
    if (!_isSelected) return Colors.grey.shade300;
    if (_showFeedback) {
      return widget.isCorrect ? AppColors.success : AppColors.error;
    }
    return baseColor;
  }
  
  Color _getTextColor(Color baseColor) {
    if (!_isSelected) return Colors.black87;
    if (_showFeedback) {
      return widget.isCorrect ? AppColors.success : AppColors.error;
    }
    return baseColor;
  }
}