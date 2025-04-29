// lib/screens/game/integer_lesson_steps.dart
import 'package:flutter/material.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/lessons/lesson_card_widget.dart';
import '../../widgets/lessons/interactive_exercise_widget.dart';
import '../../theme/app_colors.dart';
import 'number_line_painter.dart';

/// Paso 1: ¿Qué son los números enteros?
class WhatAreIntegersStep extends StatelessWidget {
  const WhatAreIntegersStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Título de la sección
          FadeAnimation(
            delay: const Duration(milliseconds: 200),
            child: Text(
              '¿Qué son los números enteros?',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tarjeta explicativa con los tipos de números
          LessonCardWidget(
            title: 'Comparación de números',
            content: Column(
              children: [
                // Explicación de números naturales vs. enteros
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.3),
                      radius: 24,
                      child: Text(
                        'ℕ',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Números Naturales',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Son los números que usamos para contar: 1, 2, 3, 4, 5...',
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
                
                const Divider(height: 30),
                
                // Explicación de números enteros
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.3),
                      radius: 24,
                      child: Text(
                        'ℤ',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Números Enteros',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Incluyen números negativos, el cero y positivos: -3, -2, -1, 0, 1, 2, 3...',
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
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Imagen explicativa
          ImageExplanationWidget(
            imagePath: 'assets/images/integers_diagram.png',
            explanation: 'Los números enteros incluyen a los naturales y también a los negativos.',
            fallbackWidget: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Z = {..., -3, -2, -1, 0, 1, 2, 3, ...}',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Conceptos clave
          KeyConceptsWidget(
            title: 'Conceptos Clave',
            concepts: [
              BulletPoint(
                text: 'Los números enteros se representan con la letra ℤ (zeta mayúscula)',
                icon: Icons.info_outline,
              ),
              BulletPoint(
                text: 'ℤ = {... -3, -2, -1, 0, 1, 2, 3, ...}',
                icon: Icons.format_list_numbered,
              ),
              BulletPoint(
                text: 'El cero es un elemento neutro: no es positivo ni negativo',
                icon: Icons.exposure_zero,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Ejercicio interactivo
          InteractiveExerciseWidget(
            title: 'Identifica números enteros',
            content: Column(
              children: [
                Text(
                  'Marca todos los números que son enteros:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Opciones seleccionables
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SelectableOptionWidget(text: '-5', isCorrect: true),
                    SelectableOptionWidget(text: '3.14', isCorrect: false),
                    SelectableOptionWidget(text: '0', isCorrect: true),
                    SelectableOptionWidget(text: '½', isCorrect: false),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SelectableOptionWidget(text: '10', isCorrect: true),
                    SelectableOptionWidget(text: '-2.5', isCorrect: false),
                    SelectableOptionWidget(text: '-8', isCorrect: true),
                    SelectableOptionWidget(text: '√2', isCorrect: false),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Paso 2: Recta numérica
class NumberLineStep extends StatelessWidget {
  const NumberLineStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Título de la sección
          FadeAnimation(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'La recta numérica',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tarjeta explicativa de la recta numérica
          LessonCardWidget(
            title: 'Representación en la recta numérica',
            content: Column(
              children: [
                // Recta numérica personalizada
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 100),
                    painter: NumberLinePainter(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Explicación
                Text(
                  'En la recta numérica, los números se organizan de menor a mayor de izquierda a derecha:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Características
                BulletPoint(
                  text: 'Los números negativos están a la izquierda del cero',
                  icon: Icons.arrow_back,
                  color: Colors.red,
                ),
                BulletPoint(
                  text: 'El cero es el punto central, el elemento neutro',
                  icon: Icons.radio_button_checked,
                  color: Colors.purple,
                ),
                BulletPoint(
                  text: 'Los números positivos están a la derecha del cero',
                  icon: Icons.arrow_forward,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tarjeta de comparación
          LessonCardWidget(
            title: 'Comparación de números enteros',
            titleColor: AppColors.secondary,
            cardColor: AppColors.secondary.withOpacity(0.1),
            content: Column(
              children: [
                Text(
                  'Para comparar números enteros, observa su posición en la recta numérica:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Ejemplos de comparación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildComparisonExample('-5 < -2', 'El -5 está más a la izquierda'),
                    _buildComparisonExample('-1 < 0', 'El -1 está más a la izquierda'),
                    _buildComparisonExample('0 < 3', 'El 0 está más a la izquierda'),
                  ],
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recuerda: Cuanto más a la derecha está un número, mayor es su valor.',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
          
          const SizedBox(height: 20),
          
          // Ejercicio interactivo
          InteractiveExerciseWidget(
            title: 'Ordena los números',
            content: NumberOrderingWidget(
              numbers: ['-3', '0', '-7', '5', '-1'],
              correctOrder: ['-7', '-3', '-1', '0', '5'],
              explanation: '-7 < -3 < -1 < 0 < 5',
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildComparisonExample(String comparison, String explanation) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            comparison,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Paso 3: Aplicaciones
class ApplicationsStep extends StatelessWidget {
  const ApplicationsStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Título de la sección
          FadeAnimation(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Aplicaciones en la vida cotidiana',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Aplicación 1: Temperatura
          LessonCardWidget(
            title: 'Temperaturas',
            titleColor: Colors.red,
            icon: Icons.thermostat,
            animationDelay: const Duration(milliseconds: 300),
            content: Column(
              children: [
                // Imagen o ilustración
                ImageExplanationWidget(
                  imagePath: 'assets/images/temperature.png',
                  explanation: 'Las temperaturas se miden con números enteros:',
                  fallbackWidget: Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thermostat, color: Colors.blue, size: 40),
                            const SizedBox(height: 4),
                            Text(
                              '-5°C',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thermostat, color: Colors.red, size: 40),
                            const SizedBox(height: 4),
                            Text(
                              '+30°C',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Ejemplos
                BulletPoint(
                  text: 'Temperaturas bajo cero: -5°C, -10°C (números negativos)',
                  icon: Icons.ac_unit,
                  color: Colors.blue,
                ),
                BulletPoint(
                  text: 'Temperatura de congelación: 0°C (cero)',
                  icon: Icons.water,
                  color: Colors.teal,
                ),
                BulletPoint(
                  text: 'Temperaturas sobre cero: 25°C, 30°C (números positivos)',
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Aplicación 2: Altitudes
          LessonCardWidget(
            title: 'Altitudes y profundidades',
            titleColor: Colors.blue,
            icon: Icons.terrain,
            animationDelay: const Duration(milliseconds: 400),
            content: Column(
              children: [
                // Visualización de altitudes
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: AltitudePainter(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Explicación
                Text(
                  'Las altitudes se miden respecto al nivel del mar:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Ejemplos
                BulletPoint(
                  text: 'Altitudes bajo el nivel del mar: -120m, -50m (números negativos)',
                  icon: Icons.waves,
                  color: Colors.blue,
                ),
                BulletPoint(
                  text: 'Nivel del mar: 0m (cero)',
                  icon: Icons.water,
                  color: Colors.teal,
                ),
                BulletPoint(
                  text: 'Altitudes sobre el nivel del mar: 200m, 500m (números positivos)',
                  icon: Icons.landscape,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Aplicación 3: Otras aplicaciones
          LessonCardWidget(
            title: 'Otras aplicaciones cotidianas',
            titleColor: AppColors.accent,
            animationDelay: const Duration(milliseconds: 500),
            content: Column(
              children: [
                // Ejemplos en tarjetas
                Row(
                  children: [
                    Expanded(
                      child: _buildApplicationCard(
                        context,
                        'Finanzas',
                        Icons.account_balance_wallet,
                        Colors.purple,
                        '+100€: Ingreso\n-50€: Gasto',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildApplicationCard(
                        context,
                        'Ascensores',
                        Icons.elevator,
                        Colors.brown,
                        '+3: 3er piso\n-2: 2° sótano',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildApplicationCard(
                        context,
                        'Historia',
                        Icons.history_edu,
                        Colors.amber,
                        '+2023: Actualidad\n-753: Fundación de Roma',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildApplicationCard(
                        context,
                        'Deportes',
                        Icons.sports_soccer,
                        Colors.green,
                        '+1: Punto ganado\n-2: Penalización',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Ejercicio interactivo
          InteractiveExerciseWidget(
            title: 'Problemas de la vida real',
            content: Column(
              children: [
                // Problema 1
                ApplicationProblemWidget(
                  problemText: 'En un día de invierno, la temperatura por la mañana era de -3°C, al mediodía subió 8 grados, y por la noche bajó 5 grados. ¿Cuál fue la temperatura final?',
                  options: ['0°C', '-5°C', '5°C', '-10°C'],
                  correctOptionIndex: 0,
                  explanation: 'Solución: -3°C + 8°C - 5°C = 0°C',
                ),
                
                const SizedBox(height: 16),
                
                // Problema 2
                ApplicationProblemWidget(
                  problemText: 'Un submarino estaba a -50 metros (bajo el nivel del mar). Luego descendió 30 metros más y finalmente subió 70 metros. ¿A qué altura quedó?',
                  options: ['-80 metros', '-10 metros', '10 metros', '-20 metros'],
                  correctOptionIndex: 1,
                  explanation: 'Solución: -50m - 30m + 70m = -10m (10 metros bajo el nivel del mar)',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Resumen final
          FadeAnimation(
            delay: const Duration(milliseconds: 700),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '¡Muy bien! Ya conoces los números enteros',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ahora estás listo para poner a prueba tus conocimientos en el juego "Rescate de Alturas", donde usarás números enteros para rescatar amigos a diferentes altitudes.',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'Completaste la lección. ¡A jugar!',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
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
  
  Widget _buildApplicationCard(BuildContext context, String title, IconData icon, Color color, String examples) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            examples,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}