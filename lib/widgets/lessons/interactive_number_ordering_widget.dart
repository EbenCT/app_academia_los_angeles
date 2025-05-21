import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import 'error_explanation_widget.dart';

class InteractiveNumberOrderingWidget extends StatefulWidget {
  final List<String> numbers;
  final List<String> correctOrder;
  final String explanation;
  final String concept;

  const InteractiveNumberOrderingWidget({
    Key? key,
    required this.numbers,
    required this.correctOrder,
    required this.explanation,
    this.concept = "ordenamiento de números enteros",
  }) : super(key: key);

  @override
  State<InteractiveNumberOrderingWidget> createState() => _InteractiveNumberOrderingWidgetState();
}

class _InteractiveNumberOrderingWidgetState extends State<InteractiveNumberOrderingWidget> {
  late List<String> _currentOrder;
  bool _showAnswer = false;
  bool _isCorrect = false;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    // Crear una copia desordenada de los números
    _currentOrder = List.from(widget.numbers);
    // Asegurarse de que estén desordenados al inicio
    _currentOrder.shuffle();
  }

  bool _checkOrder() {
    // Comparar si el orden actual coincide con el correcto
    if (_currentOrder.length != widget.correctOrder.length) return false;
    
    for (int i = 0; i < _currentOrder.length; i++) {
      if (_currentOrder[i] != widget.correctOrder[i]) return false;
    }
    
    return true;
  }

  void _verifyAnswer() {
    final isCorrect = _checkOrder();
    
    setState(() {
      _showAnswer = true;
      _isCorrect = isCorrect;
      
      // Mostrar explicación solo si es incorrecto
      if (!isCorrect) {
        _showExplanation = true;
      }
    });
  }

  void _hideExplanation() {
    setState(() {
      _showExplanation = false;
    });
  }

  void _resetActivity() {
    setState(() {
      _currentOrder.shuffle();
      _showAnswer = false;
      _isCorrect = false;
      _showExplanation = false;
    });
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
        
        // Números ordenables con efectos mejorados
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _showAnswer 
                  ? (_isCorrect ? AppColors.success : AppColors.error)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildDraggableNumbers(),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Botones de acción
        if (!_showAnswer)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _verifyAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text(
                      "Comprobar",
                      style: TextStyle(fontFamily: 'Comic Sans MS'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton(
                onPressed: _resetActivity,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text(
                      "Reiniciar",
                      style: TextStyle(fontFamily: 'Comic Sans MS'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        
        if (_showAnswer) ...[
          // Mensaje de resultado
          FadeAnimation(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect 
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.error_outline,
                        color: _isCorrect ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? '¡Correcto!' : 'Inténtalo de nuevo',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  if (_isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.explanation,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_showExplanation)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showExplanation = true;
                              });
                            },
                            icon: Icon(Icons.lightbulb_outline),
                            label: Text("Ver explicación"),
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
                ],
              ),
            ),
          ),
          
          // Mostrar orden correcto si es incorrecto
          if (!_isCorrect && !_showExplanation)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "Recuerda: Los números se ordenan de menor a mayor en la recta numérica",
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Botones adicionales para respuesta correcta
          if (_isCorrect)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: _resetActivity,
                icon: Icon(Icons.refresh),
                label: Text("Volver a practicar"),
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
              userAnswer: _currentOrder.join(", "),
              correctAnswer: widget.correctOrder.join(", "),
              lessonContext: "Ordenamos números enteros de menor a mayor en la recta numérica",
              onDismiss: _hideExplanation,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDraggableNumbers() {
    return _currentOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final number = entry.value;
      
      // Color basado en el valor
      Color numberColor;
      if (number == '0') {
        numberColor = Colors.purple;
      } else if (number.startsWith('-')) {
        numberColor = Colors.red;
      } else {
        numberColor = Colors.blue;
      }
      
      return Draggable<Map<String, dynamic>>(
        // Usar Map para transportar tanto el número como su índice
        data: {'number': number, 'index': index},
        feedback: _buildNumberBubble(number, numberColor, true),
        childWhenDragging: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.swap_horiz,
              color: Colors.grey,
            ),
          ),
        ),
        child: DragTarget<Map<String, dynamic>>(
          onWillAccept: (data) => data != null && data['number'] != number,
          onAccept: (data) {
            // Intercambiar posiciones
            setState(() {
              final draggedIndex = data['index'] as int;
              final thisIndex = index;
              
              // Intercambiar los elementos
              final temp = _currentOrder[thisIndex];
              _currentOrder[thisIndex] = _currentOrder[draggedIndex];
              _currentOrder[draggedIndex] = temp;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty 
                    ? Colors.grey.withOpacity(0.2) 
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: _buildNumberBubble(number, numberColor, false),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildNumberBubble(String number, Color color, bool isDragging) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 3,
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}