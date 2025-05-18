import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import 'error_explanation_widget.dart';

class InteractiveComparisonWidget extends StatefulWidget {
  final String num1;
  final String num2;
  final String correctSymbol;
  final String concept;

  const InteractiveComparisonWidget({
    Key? key,
    required this.num1,
    required this.num2,
    required this.correctSymbol,
    this.concept = "comparación de números enteros",
  }) : super(key: key);

  @override
  State<InteractiveComparisonWidget> createState() => _InteractiveComparisonWidgetState();
}

class _InteractiveComparisonWidgetState extends State<InteractiveComparisonWidget> {
  String? _selectedSymbol;
  bool _showFeedback = false;
  bool _showExplanation = false;

  Color _getNumberColor(String number) {
    if (number == '0') {
      return Colors.purple;
    } else if (number.startsWith('-')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  void _selectSymbol(String symbol) {
    setState(() {
      _selectedSymbol = symbol;
      _showFeedback = true;
      
      // Mostrar explicación solo si es incorrecto
      if (symbol != widget.correctSymbol) {
        _showExplanation = true;
      }
    });
  }

  void _resetActivity() {
    setState(() {
      _selectedSymbol = null;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primer número
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getNumberColor(widget.num1).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                   widget.num1,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getNumberColor(widget.num1),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 15),
              
              // Opciones de símbolos
              Column(
                children: [
                  Row(
                    children: [
                      _buildSymbolOption("<"),
                      const SizedBox(width: 15),
                      _buildSymbolOption(">"),
                    ],
                  ),
                  if (_showFeedback)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedSymbol == widget.correctSymbol 
                                ? Icons.check_circle 
                                : Icons.cancel,
                            color: _selectedSymbol == widget.correctSymbol 
                                ? AppColors.success 
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _selectedSymbol == widget.correctSymbol 
                                ? "¡Correcto!" 
                                : "Incorrecto",
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedSymbol == widget.correctSymbol 
                                  ? AppColors.success 
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 15),
              
              // Segundo número
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getNumberColor(widget.num2).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.num2,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getNumberColor(widget.num2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Botones de acción después de la selección
        if (_showFeedback && !_showExplanation) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedSymbol != widget.correctSymbol)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showExplanation = true;
                    });
                  },
                  icon: Icon(Icons.lightbulb_outline, size: 18),
                  label: Text(
                    "Ver explicación",
                    style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _resetActivity,
                icon: Icon(Icons.refresh, size: 18),
                label: Text(
                  "Intentar de nuevo",
                  style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
        
        // Widget de explicación
        if (_showExplanation)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ErrorExplanationWidget(
              concept: widget.concept,
              userAnswer: "${widget.num1} ${_selectedSymbol} ${widget.num2}",
              correctAnswer: "${widget.num1} ${widget.correctSymbol} ${widget.num2}",
              lessonContext: "Comparando números enteros en la recta numérica",
              onDismiss: _hideExplanation,
            ),
          ),
      ],
    );
  }

  Widget _buildSymbolOption(String symbol) {
    final bool isSelected = _selectedSymbol == symbol;
    final bool isCorrect = symbol == widget.correctSymbol;
    
    // Determinar colores basados en el estado
    Color bgColor, borderColor, textColor;
    
    if (!_showFeedback || !isSelected) {
      bgColor = isSelected ? Colors.purple.withOpacity(0.2) : Colors.grey.withOpacity(0.1);
      borderColor = isSelected ? Colors.purple : Colors.transparent;
      textColor = isSelected ? Colors.purple : Colors.black54;
    } else {
      bgColor = isCorrect ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      textColor = isCorrect ? AppColors.success : AppColors.error;
    }
    
    return GestureDetector(
      onTap: _showFeedback ? null : () => _selectSymbol(symbol),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}