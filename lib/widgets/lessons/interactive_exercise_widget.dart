// lib/widgets/lessons/interactive_exercise_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget base para ejercicios interactivos
class InteractiveExerciseWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  
  const InteractiveExerciseWidget({
    Key? key,
    required this.title,
    required this.content,
    this.icon,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary.withOpacity(0.1);
    final border = borderColor ?? AppColors.primary.withOpacity(0.3);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Título del ejercicio
          Row(
            children: [
              Icon(
                icon ?? Icons.fitness_center, 
                color: borderColor?.withOpacity(1.0) ?? AppColors.primary
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: borderColor?.withOpacity(1.0) ?? AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contenido del ejercicio
          content,
        ],
      ),
    );
  }
}

/// Widget para opciones seleccionables (como tipos de número)
class SelectableOptionWidget extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final Function(bool)? onSelected;
  
  const SelectableOptionWidget({
    Key? key,
    required this.text,
    required this.isCorrect,
    this.onSelected,
  }) : super(key: key);

  @override
  State<SelectableOptionWidget> createState() => _SelectableOptionWidgetState();
}

class _SelectableOptionWidgetState extends State<SelectableOptionWidget> {
  bool _isSelected = false;
  bool _showFeedback = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
          _showFeedback = _isSelected;
        });
        
        if (widget.onSelected != null) {
          widget.onSelected!(_isSelected);
        }
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: _isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
              ),
            ),
            if (_showFeedback)
              Positioned(
                top: 0,
                right: 0,
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
  
  Color _getBackgroundColor() {
    if (!_isSelected) return Colors.white;
    if (_showFeedback) {
      return widget.isCorrect 
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
    }
    return AppColors.primary.withOpacity(0.1);
  }
  
  Color _getBorderColor() {
    if (!_isSelected) return Colors.grey.shade300;
    if (_showFeedback) {
      return widget.isCorrect ? AppColors.success : AppColors.error;
    }
    return AppColors.primary;
  }
  
  Color _getTextColor() {
    if (!_isSelected) return Colors.black87;
    if (_showFeedback) {
      return widget.isCorrect ? AppColors.success : AppColors.error;
    }
    return AppColors.primary;
  }
}

/// Widget para problemas de aplicación con respuestas
class ApplicationProblemWidget extends StatefulWidget {
  final String problemText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  
  const ApplicationProblemWidget({
    Key? key,
    required this.problemText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  }) : super(key: key);

  @override
  State<ApplicationProblemWidget> createState() => _ApplicationProblemWidgetState();
}

class _ApplicationProblemWidgetState extends State<ApplicationProblemWidget> {
  int? _selectedOptionIndex;
  bool _showExplanation = false;
  
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
          Text(
            widget.problemText,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opciones seleccionables
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              widget.options.length,
              (index) => _buildOptionButton(index),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Explicación (mostrada después de seleccionar)
          if (_showExplanation)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.explanation,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
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
    
    if (isSelected && _showExplanation) {
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
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
          _showExplanation = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          widget.options[index],
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Widget para ordenar números en la recta numérica
class NumberOrderingWidget extends StatefulWidget {
  final List<String> numbers;
  final List<String> correctOrder;
  final String explanation;
  
  const NumberOrderingWidget({
    Key? key,
    required this.numbers,
    required this.correctOrder,
    required this.explanation,
  }) : super(key: key);

  @override
  State<NumberOrderingWidget> createState() => _NumberOrderingWidgetState();
}

class _NumberOrderingWidgetState extends State<NumberOrderingWidget> {
  List<String> _currentOrder = [];
  bool _showAnswer = false;
  
  @override
  void initState() {
    super.initState();
    // Copiar la lista para no modificar la original
    _currentOrder = List.from(widget.numbers);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ordena estos números de menor a mayor:',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Números para ordenar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _currentOrder.map((number) => _buildDraggableNumber(number)).toList(),
        ),
        
        const SizedBox(height: 20),
        
        // Botón para verificar respuesta
        if (!_showAnswer)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAnswer = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Verificar respuesta',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
          ),
        
        // Respuesta correcta
        if (_showAnswer)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Respuesta correcta',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.explanation,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildDraggableNumber(String number) {
    return Draggable<String>(
      data: number,
      feedback: Material(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: DragTarget<String>(
        onWillAccept: (data) => data != null && data != number,
        onAccept: (data) {
          // Intercambiar posiciones
          setState(() {
            final dataIndex = _currentOrder.indexOf(data);
            final thisIndex = _currentOrder.indexOf(number);
            _currentOrder[dataIndex] = number;
            _currentOrder[thisIndex] = data;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty ? AppColors.primary.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}