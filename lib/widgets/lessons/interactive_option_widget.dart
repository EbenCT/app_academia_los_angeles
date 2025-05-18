import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InteractiveOptionWidget extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final Function(bool isSelected, bool isCorrect)? onSelected;
  final bool showFeedbackOnTap;
  final bool isCircular;
  final double? width;
  final double? height;
  final Color? color;
  final bool disabled;

  const InteractiveOptionWidget({
    Key? key,
    required this.text,
    required this.isCorrect,
    this.onSelected,
    this.showFeedbackOnTap = true,
    this.isCircular = false,
    this.width,
    this.height = 60,
    this.color,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<InteractiveOptionWidget> createState() => _InteractiveOptionWidgetState();
}

class _InteractiveOptionWidgetState extends State<InteractiveOptionWidget> {
  bool _isSelected = false;
  bool _showFeedback = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTap: widget.disabled ? null : () {
        setState(() {
          _isSelected = !_isSelected;
          if (widget.showFeedbackOnTap) {
            _showFeedback = _isSelected;
          }
        });

        if (widget.onSelected != null) {
          widget.onSelected!(_isSelected, widget.isCorrect);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _getBackgroundColor(baseColor),
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(15),
          border: Border.all(
            color: _getBorderColor(baseColor),
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (_isSelected && !widget.disabled)
              BoxShadow(
                color: _showFeedback
                    ? (widget.isCorrect ? AppColors.success : AppColors.error).withOpacity(0.3)
                    : baseColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: widget.isCircular ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: widget.disabled 
                    ? Colors.grey 
                    : _getTextColor(baseColor),
              ),
              textAlign: TextAlign.center,
            ),
            if (_showFeedback && _isSelected)
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
    if (widget.disabled) return Colors.grey.shade200;
    if (!_isSelected) return Colors.white;
    if (_showFeedback) {
      return widget.isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
    }
    return baseColor.withOpacity(0.1);
  }

  Color _getBorderColor(Color baseColor) {
    if (widget.disabled) return Colors.grey.shade300;
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

  void reset() {
    setState(() {
      _isSelected = false;
      _showFeedback = false;
    });
  }

  void showFeedback() {
    if (_isSelected) {
      setState(() {
        _showFeedback = true;
      });
    }
  }
}