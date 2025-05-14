// lib/screens/game/integer_lesson_steps.dart
import 'package:flutter/material.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../theme/app_colors.dart';
import 'number_line_painter.dart';

/// Paso 1: ¿Qué son los números enteros? - Enfocado en práctica con teoría mínima
class WhatAreIntegersStep extends StatelessWidget {
  const WhatAreIntegersStep({Key? key}) : super(key: key);

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
          
          // MINI PRÁCTICA 1: Identificar enteros - Mejorada y destacada
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
                
                // Opciones seleccionables en filas mejoradas
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSelectableNumber('-5', true),
                    _buildSelectableNumber('3.14', false),
                    _buildSelectableNumber('0', true),
                    _buildSelectableNumber('10', true),
                    _buildSelectableNumber('-2.5', false),
                    _buildSelectableNumber('½', false),
                    _buildSelectableNumber('-8', true),
                    _buildSelectableNumber('√2', false),
                    _buildSelectableNumber('6', true),
                  ],
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
          fontSize: 18, // Reducido para evitar desbordamiento
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildSelectableNumber(String number, bool isCorrect) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isSelected = false;
        bool showFeedback = false;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              showFeedback = isSelected;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: !isSelected
                  ? Colors.white
                  : (showFeedback
                      ? (isCorrect
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2))
                      : AppColors.primary.withOpacity(0.2)),
              shape: BoxShape.circle,
              border: Border.all(
                color: !isSelected
                    ? Colors.grey.shade300
                    : (showFeedback
                        ? (isCorrect ? AppColors.success : AppColors.error)
                        : AppColors.primary),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: !isSelected
                        ? Colors.black87
                        : (showFeedback
                            ? (isCorrect ? AppColors.success : AppColors.error)
                            : AppColors.primary),
                  ),
                ),
                if (showFeedback)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paso 2: Recta numérica - Enfocado en práctica con teoría mínima
class NumberLineStep extends StatelessWidget {
  const NumberLineStep({Key? key}) : super(key: key);

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
                  // Recta numérica optimizada para evitar desbordamiento
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomPaint(
                        size: const Size(double.infinity, 80),
                        painter: NumberLinePainter(
                          textScaleFactor: 0.8, // Reducido para evitar desbordamiento
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
          
          // MINI PRÁCTICA 2: Ordenar números - Mejorada y destacada
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
                
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '¡Arrastra los números para ordenarlos de menor a mayor!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Números ordenables (con mejora visual)
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['-7', '-3', '-1', '0', '5'].map((number) => 
                      _buildDraggableNumber(number, context)
                    ).toList(),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Resultado esperado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Solución correcta:',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '-7 < -3 < -1 < 0 < 5',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'El menor está a la izquierda, el mayor a la derecha',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // MINI PRÁCTICA 3: Comparación de enteros
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
                _buildComparisonExercise('-5', '2', '<', context),
                const SizedBox(height: 12),
                _buildComparisonExercise('0', '-3', '>', context),
                const SizedBox(height: 12),
                _buildComparisonExercise('-2', '-7', '>', context),
                
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
          fontSize: 18, // Reducido para evitar desbordamiento
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
  
  Widget _buildDraggableNumber(String number, BuildContext context) {
    // Color basado en el valor
    Color numberColor;
    if (number == '0') {
      numberColor = Colors.purple;
    } else if (number.startsWith('-')) {
      numberColor = Colors.red;
    } else {
      numberColor = Colors.blue;
    }
    
    return Draggable<String>(
      data: number,
      feedback: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: numberColor.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
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
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              numberColor.withOpacity(0.8),
              numberColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: numberColor.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildComparisonExercise(String num1, String num2, String correctSymbol, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        String selectedSymbol = '';
        bool showFeedback = false;
        
        return Container(
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNumberColor(num1).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num1,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getNumberColor(num1),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 15),
              
              // Opciones de símbolos
              Row(
                children: [
                  // Opción <
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSymbol = '<';
                        showFeedback = true;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedSymbol == '<'
                            ? (showFeedback
                                ? (correctSymbol == '<'
                                    ? AppColors.success.withOpacity(0.2)
                                    : AppColors.error.withOpacity(0.2))
                                : Colors.purple.withOpacity(0.2))
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedSymbol == '<'
                              ? (showFeedback
                                  ? (correctSymbol == '<'
                                      ? AppColors.success
                                      : AppColors.error)
                                  : Colors.purple)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '<',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selectedSymbol == '<'
                                ? (showFeedback
                                    ? (correctSymbol == '<'
                                        ? AppColors.success
                                        : AppColors.error)
                                    : Colors.purple)
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Opción >
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSymbol = '>';
                        showFeedback = true;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedSymbol == '>'
                            ? (showFeedback
                                ? (correctSymbol == '>'
                                    ? AppColors.success.withOpacity(0.2)
                                    : AppColors.error.withOpacity(0.2))
                                : Colors.purple.withOpacity(0.2))
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedSymbol == '>'
                              ? (showFeedback
                                  ? (correctSymbol == '>'
                                      ? AppColors.success
                                      : AppColors.error)
                                  : Colors.purple)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '>',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selectedSymbol == '>'
                                ? (showFeedback
                                    ? (correctSymbol == '>'
                                        ? AppColors.success
                                        : AppColors.error)
                                    : Colors.purple)
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 15),
              
              // Segundo número
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNumberColor(num2).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num2,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getNumberColor(num2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 15),
              
              // Indicador de correcto/incorrecto
              if (showFeedback)
                Icon(
                  selectedSymbol == correctSymbol
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: selectedSymbol == correctSymbol
                      ? AppColors.success
                      : AppColors.error,
                  size: 24,
                ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getNumberColor(String number) {
    if (number == '0') {
      return Colors.purple;
    } else if (number.startsWith('-')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}

/// Paso 3: Aplicaciones - Enfocado en práctica con teoría mínima
class ApplicationsStep extends StatelessWidget {
  const ApplicationsStep({Key? key}) : super(key: key);

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
          
          // MINI PRÁCTICA 4: Problema con temperaturas
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
                
                // Problema
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: Colors.red,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'En un día de invierno, la temperatura por la mañana era de -3°C, al mediodía subió 8 grados, y por la noche bajó 5 grados. ¿Cuál fue la temperatura final?',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Opciones interactivas
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTemperatureOption('0°C', true, context),
                    _buildTemperatureOption('-5°C', false, context),
                    _buildTemperatureOption('5°C', false, context),
                    _buildTemperatureOption('-10°C', false, context),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Solución (inicialmente oculta - se mostraría al seleccionar)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Solución:',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '-3°C + 8°C - 5°C = 0°C',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // MINI PRÁCTICA 5: Problema con altitudes
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
                
                // Problema
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sailing,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Un submarino estaba a -50 metros (bajo el nivel del mar). Luego descendió 30 metros más y finalmente subió 70 metros. ¿A qué altura quedó?',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Opciones interactivas
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildAltitudeOption('-80 metros', false, context),
                    _buildAltitudeOption('-10 metros', true, context),
                    _buildAltitudeOption('10 metros', false, context),
                    _buildAltitudeOption('-20 metros', false, context),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Solución (inicialmente oculta - se mostraría al seleccionar)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Solución:',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '-50m - 30m + 70m = -10m',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '10 metros bajo el nivel del mar',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Resumen visual mínimo
          FadeAnimation(
            delay: const Duration(milliseconds: 600),
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
              child: const Column(
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
                ],
              ),
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
          fontSize: 18, // Reducido para evitar desbordamiento
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildTemperatureOption(String text, bool isCorrect, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isSelected = false;
        bool showFeedback = false;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              showFeedback = isSelected;
            });
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isSelected
                      ? (showFeedback
                          ? (isCorrect
                              ? AppColors.success.withOpacity(0.7)
                              : AppColors.error.withOpacity(0.7))
                          : Colors.red.withOpacity(0.7))
                      : Colors.red.withOpacity(0.3),
                  isSelected
                      ? (showFeedback
                          ? (isCorrect
                              ? AppColors.success.withOpacity(0.4)
                              : AppColors.error.withOpacity(0.4))
                          : Colors.red.withOpacity(0.4))
                      : Colors.red.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: showFeedback
                            ? (isCorrect
                                ? AppColors.success.withOpacity(0.5)
                                : AppColors.error.withOpacity(0.5))
                            : Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
              border: Border.all(
                color: isSelected
                    ? (showFeedback
                        ? (isCorrect ? AppColors.success : AppColors.error)
                        : Colors.red)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (showFeedback && isCorrect)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAltitudeOption(String text, bool isCorrect, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isSelected = false;
        bool showFeedback = false;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              showFeedback = isSelected;
            });
          },
          child: Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isSelected
                      ? (showFeedback
                          ? (isCorrect
                              ? AppColors.success.withOpacity(0.7)
                              : AppColors.error.withOpacity(0.7))
                          : Colors.blue.withOpacity(0.7))
                      : Colors.blue.withOpacity(0.3),
                  isSelected
                      ? (showFeedback
                          ? (isCorrect
                              ? AppColors.success.withOpacity(0.4)
                              : AppColors.error.withOpacity(0.4))
                          : Colors.blue.withOpacity(0.4))
                      : Colors.blue.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: showFeedback
                            ? (isCorrect
                                ? AppColors.success.withOpacity(0.5)
                                : AppColors.error.withOpacity(0.5))
                            : Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
              border: Border.all(
                color: isSelected
                    ? (showFeedback
                        ? (isCorrect ? AppColors.success : AppColors.error)
                        : Colors.blue)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showFeedback && isCorrect)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}