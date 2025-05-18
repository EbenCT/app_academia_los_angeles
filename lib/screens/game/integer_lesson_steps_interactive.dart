import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/lessons/error_explanation_widget.dart';
import '../../widgets/lessons/interactive_comparison_widget.dart';
import '../../widgets/lessons/interactive_number_ordering_widget.dart';
import '../../widgets/lessons/interactive_option_widget.dart';
import '../../widgets/lessons/interactive_problem_widget.dart';
import 'number_line_painter.dart';

/// Paso 1 mejorado: ¿Qué son los números enteros? - Con interactividad real
class WhatAreIntegersStepInteractive extends StatefulWidget {
  const WhatAreIntegersStepInteractive({Key? key}) : super(key: key);

  @override
  State<WhatAreIntegersStepInteractive> createState() => _WhatAreIntegersStepInteractiveState();
}

class _WhatAreIntegersStepInteractiveState extends State<WhatAreIntegersStepInteractive> {
  // Estados para rastrear las selecciones y feedback del usuario
  final Map<String, bool> _selectedNumbers = {};
  bool _hasMadeSelection = false;
  bool _hasCheckedAnswers = false;
  bool _showExplanation = false;
  String _incorrectSelection = "";

  // Definir los números y cuáles son enteros
  final Map<String, bool> _numberOptions = {
    "-5": true,
    "3.14": false,
    "0": true,
    "10": true,
    "-2.5": false,
    "½": false,
    "-8": true,
    "√2": false,
    "6": true,
  };

  void _toggleNumber(String number, bool isCorrect) {
    setState(() {
      _hasMadeSelection = true;
      if (_selectedNumbers.containsKey(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers[number] = isCorrect;
      }
    });
  }

  void _checkAnswers() {
    setState(() {
      _hasCheckedAnswers = true;
      
      // Revisar si hay alguna selección incorrecta
      for (var entry in _selectedNumbers.entries) {
        if (!entry.value) {
          _incorrectSelection = entry.key;
          _showExplanation = true;
          break;
        }
      }
      
      // También revisar si falta seleccionar algún número entero
      if (!_showExplanation) {
        for (var entry in _numberOptions.entries) {
          if (entry.value && !_selectedNumbers.containsKey(entry.key)) {
            _incorrectSelection = "faltó seleccionar ${entry.key}";
            _showExplanation = true;
            break;
          }
        }
      }
    });
  }

  void _resetActivity() {
    setState(() {
      _selectedNumbers.clear();
      _hasMadeSelection = false;
      _hasCheckedAnswers = false;
      _showExplanation = false;
      _incorrectSelection = "";
    });
  }

  void _hideExplanation() {
    setState(() {
      _showExplanation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Título con tamaño reducido para evitar desbordamiento
          _buildSimpleTitle('Los números enteros', context),
          const SizedBox(height: 20),
          
          // Breve introducción visual (mínima teoría)
          FadeAnimation(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Símbolo
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: const Text(
                      'ℤ',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6200EA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Breve explicación
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Los enteros incluyen:',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '• Negativos: -3, -2, -1\n• Cero: 0\n• Positivos: 1, 2, 3',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // MINI PRÁCTICA 1: Identificar enteros - Interactiva
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la práctica
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRÁCTICA: Identificar números',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6200EA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '¡Toca todos los números que son enteros!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Opciones seleccionables interactivas
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _numberOptions.entries.map((entry) {
                    final number = entry.key;
                    final isCorrect = entry.value;
                    final isSelected = _selectedNumbers.containsKey(number);
                    final bool showFeedback = _hasCheckedAnswers && isSelected;
                    
                    return InteractiveOptionWidget(
                      text: number,
                      isCorrect: isCorrect,
                      onSelected: _hasCheckedAnswers ? null : (selected, correct) {
                        _toggleNumber(number, isCorrect);
                      },
                      showFeedbackOnTap: false,
                      isCircular: true,
                      width: 60,
                      height: 60,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // Botones de acción
                if (!_hasCheckedAnswers)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _hasMadeSelection ? _checkAnswers : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check),
                            SizedBox(width: 8),
                            Text(
                              "Verificar respuestas",
                              style: TextStyle(fontFamily: 'Comic Sans MS'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (!_showExplanation) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _incorrectSelection.isEmpty
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _incorrectSelection.isEmpty
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
                              _incorrectSelection.isEmpty
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: _incorrectSelection.isEmpty
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _incorrectSelection.isEmpty
                                  ? '¡Correcto!'
                                  : 'Hay errores en tu selección',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _incorrectSelection.isEmpty
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        if (_incorrectSelection.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Has identificado correctamente todos los números enteros. Los enteros son números enteros o completos sin partes fraccionarias o decimales.",
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_incorrectSelection.isNotEmpty)
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
                        label: Text(_incorrectSelection.isEmpty 
                            ? "Practicar de nuevo" 
                            : "Intentar de nuevo"),
                      ),
                    ],
                  ),
                ],
                
                // Widget de explicación
                if (_showExplanation)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ErrorExplanationWidget(
                      concept: "números enteros",
                      userAnswer: _incorrectSelection,
                      correctAnswer: "Números enteros son los negativos, cero y positivos, sin decimales ni fracciones",
                      lessonContext: "Identificando números enteros",
                      onDismiss: _hideExplanation,
                    ),
                  ),
                
                const SizedBox(height: 15),
                
                // Pista
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Los enteros no incluyen fracciones, decimales o raíces.',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildSimpleTitle(String title, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Paso 2 mejorado: Recta numérica - Con interactividad real
class NumberLineStepInteractive extends StatefulWidget {
  const NumberLineStepInteractive({Key? key}) : super(key: key);

  @override
  State<NumberLineStepInteractive> createState() => _NumberLineStepInteractiveState();
}

class _NumberLineStepInteractiveState extends State<NumberLineStepInteractive> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Título simplificado para evitar desbordamiento
          _buildSimpleTitle('La recta numérica', context),
          const SizedBox(height: 20),
          
          // Recta numérica (breve demostración visual)
          FadeAnimation(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Recta numérica interactiva y optimizada
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: () {
                          // Mostrar una animación o destacar valores en la recta
                          _showNumberLineInteraction(context);
                        },
                        child: CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: NumberLinePainter(
                            textScaleFactor: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Mini-leyenda simplificada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDirectionLabel('Negativos', Colors.red),
                      _buildDirectionLabel('Cero', Colors.purple),
                      _buildDirectionLabel('Positivos', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // MINI PRÁCTICA 2: Ordenar números - Mejorada con interactividad
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la práctica
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRÁCTICA: Ordenar números enteros',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Widget interactivo de ordenamiento
                InteractiveNumberOrderingWidget(
                  numbers: ['-7', '-3', '-1', '0', '5'],
                  correctOrder: ['-7', '-3', '-1', '0', '5'],
                  explanation: 'Los números se ordenan de menor a mayor en la recta numérica. Cuanto más a la izquierda, menor es el número.',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // MINI PRÁCTICA 3: Comparación de enteros - Mejorada con interactividad
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.purple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la práctica
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRÁCTICA: Comparar números',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '¡Escoge el símbolo correcto (< ó >) para cada comparación!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Comparaciones interactivas
                InteractiveComparisonWidget(
                  num1: '-5',
                  num2: '2',
                  correctSymbol: '<',
                  concept: 'comparación de números enteros',
                ),
                
                const SizedBox(height: 16),
                
                InteractiveComparisonWidget(
                  num1: '0',
                  num2: '-3',
                  correctSymbol: '>',
                  concept: 'comparación de números enteros',
                ),
                
                const SizedBox(height: 16),
                
                InteractiveComparisonWidget(
                  num1: '-2',
                  num2: '-7',
                  correctSymbol: '>',
                  concept: 'comparación de números enteros',
                ),
                
                const SizedBox(height: 15),
                
                // Regla
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recuerda: Cuanto más a la derecha está un número en la recta, mayor es.',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showNumberLineInteraction(BuildContext context) {
    // Mostrar un diálogo interactivo para explicar mejor la recta numérica
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Explorando la recta numérica',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'La recta numérica es una representación visual de los números ordenados de menor a mayor, de izquierda a derecha.',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: CustomPaint(
                size: Size(double.infinity, 150),
                painter: NumberLinePainter(textScaleFactor: 1.2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '• Los números a la izquierda de 0 son negativos\n• Los números a la derecha de 0 son positivos\n• Cuanto más a la izquierda, menor es el número',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '¡Entendido!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleTitle(String title, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildDirectionLabel(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Paso 3 mejorado: Aplicaciones - Con interactividad real
class ApplicationsStepInteractive extends StatefulWidget {
  const ApplicationsStepInteractive({Key? key}) : super(key: key);

  @override
  State<ApplicationsStepInteractive> createState() => _ApplicationsStepInteractiveState();
}

class _ApplicationsStepInteractiveState extends State<ApplicationsStepInteractive> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Título simplificado para evitar desbordamiento
          _buildSimpleTitle('Aplicaciones', context),
          const SizedBox(height: 20),
          
          // Breve introducción (mínima teoría)
          FadeAnimation(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Los números enteros están presentes en: temperaturas, altitudes, finanzas, sótanos y pisos, años pasados y futuros.',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // MINI PRÁCTICA 4: Problema con temperaturas - Mejorada con interactividad
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la práctica
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '4',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRÁCTICA: Temperaturas',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Problema de temperatura interactivo
                InteractiveProblemWidget(
                  problemText: 'En un día de invierno, la temperatura por la mañana era de -3°C, al mediodía subió 8 grados, y por la noche bajó 5 grados. ¿Cuál fue la temperatura final?',
                  options: ['0°C', '-5°C', '5°C', '-10°C'],
                  correctOptionIndex: 0,
                  explanation: '-3°C + 8°C - 5°C = 0°C',
                  concept: 'operaciones con temperaturas',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // MINI PRÁCTICA 5: Problema con altitudes - Mejorada con interactividad
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.teal.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la práctica
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '5',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRÁCTICA: Altitudes',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Problema de altitud interactivo
                InteractiveProblemWidget(
                  problemText: 'Un submarino estaba a -50 metros (bajo el nivel del mar). Luego descendió 30 metros más y finalmente subió 70 metros. ¿A qué altura quedó?',
                  options: ['-80 metros', '-10 metros', '10 metros', '-20 metros'],
                  correctOptionIndex: 1,
                  explanation: '-50m - 30m + 70m = -10m (10 metros bajo el nivel del mar)',
                  concept: 'operaciones con altitudes',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Resumen visual mínimo e interactivo
          FadeAnimation(
            delay: const Duration(milliseconds: 600),
            child: GestureDetector(
              onTap: () => _showPreGameDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.7),
                      AppColors.success.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '¡Ya estás listo para jugar!',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'En el juego "Rescate de Alturas" usarás números enteros para rescatar amigos a diferentes altitudes.',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Indicador visual para tocar
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '¡Toca para ver un avance del juego!',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showPreGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¡Prepárate para el Rescate!',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
                image: DecorationImage(
                  image: AssetImage('assets/images/game_preview.png'),
                  fit: BoxFit.cover,
                ),
              ),
              // Si no tienes la imagen, puedes usar un placeholder:
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: AppColors.primary,
                      size: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "¡Vista previa del juego!",
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Diferentes altitudes, desde -150m hasta 400m",
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'En este juego moverás a tu astronauta usando enteros positivos y negativos para llegar a la altitud correcta.',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAltitudeExample(300, Colors.purple),
                SizedBox(width: 12),
                _buildAltitudeExample(0, Colors.blue),
                SizedBox(width: 12),
                _buildAltitudeExample(-75, Colors.green),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Volver a la lección',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mostrar un mensaje de que el juego se cargará al terminar la lección
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '¡Completa la lección para desbloquear el juego!',
                    style: TextStyle(fontFamily: 'Comic Sans MS'),
                  ),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '¡Quiero jugar!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAltitudeExample(int altitude, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            '$altitude m',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            altitude > 0 
                ? 'Sobre el mar' 
                : altitude < 0 
                    ? 'Bajo el mar' 
                    : 'Nivel del mar',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleTitle(String title, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}