import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import 'error_explanation_widget.dart';

class InteractiveProblemWidget extends StatefulWidget {
  final String problemText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String concept;

  const InteractiveProblemWidget({
    Key? key,
    required this.problemText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.concept = "aplicación de números enteros",
  }) : super(key: key);

  @override
  State<InteractiveProblemWidget> createState() => _InteractiveProblemWidgetState();
}

class _InteractiveProblemWidgetState extends State<InteractiveProblemWidget> {
  int? _selectedOptionIndex;
  bool _showFeedback = false;
  bool _showExplanation = false;

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
      _showFeedback = true;
      
      // Mostrar explicación solo si es incorrecto
      if (index != widget.correctOptionIndex) {
        _showExplanation = true;
      }
    });
  }

  void _resetActivity() {
    setState(() {
      _selectedOptionIndex = null;
      _showFeedback = false;
      _showExplanation = false;
    });
  }

  void _hideExplanation() {
    setState(() {
      _showExplanation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto del problema
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.question_mark_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.problemText,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Opciones seleccionables
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(
              widget.options.length,
              (index) => _buildOptionButton(index),
            ),
          ),
          
          // Mensaje de resultado
          if (_showFeedback && !_showExplanation) ...[
            const SizedBox(height: 16),
            FadeAnimation(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedOptionIndex == widget.correctOptionIndex
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedOptionIndex == widget.correctOptionIndex
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedOptionIndex == widget.correctOptionIndex
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: _selectedOptionIndex == widget.correctOptionIndex
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedOptionIndex == widget.correctOptionIndex
                            ? "¡Correcto! ${widget.explanation}"
                            : "Inténtalo de nuevo",
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _selectedOptionIndex == widget.correctOptionIndex
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Botones adicionales para respuesta incorrecta
          if (_showFeedback && _selectedOptionIndex != widget.correctOptionIndex && !_showExplanation) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showExplanation = true;
                    });
                  },
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text("Explícame"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _resetActivity,
                  icon: Icon(Icons.refresh),
                  label: Text("Intentar de nuevo"),
                ),
              ],
            ),
          ],
          
          // Botones adicionales para respuesta correcta
          if (_showFeedback && _selectedOptionIndex == widget.correctOptionIndex) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _resetActivity,
                icon: Icon(Icons.refresh),
                label: Text("Otro problema"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
          ],
          
          // Widget de explicación
          if (_showExplanation)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ErrorExplanationWidget(
                concept: widget.concept,
                userAnswer: widget.options[_selectedOptionIndex!],
                correctAnswer: widget.options[widget.correctOptionIndex],
                lessonContext: widget.problemText,
                onDismiss: _hideExplanation,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == widget.correctOptionIndex;
    
    // Colores según el estado
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;
    
    if (isSelected && _showFeedback) {
      backgroundColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      textColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }
    
    return GestureDetector(
      onTap: _showFeedback ? null : () => _selectOption(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          widget.options[index],
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}