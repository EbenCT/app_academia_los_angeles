import 'package:flutter/material.dart';
import '../../config/routes.dart';
import 'integer_lesson_steps_interactive.dart';
import 'lesson_screen_base_interactive.dart';

/// Pantalla principal interactiva para la lección sobre números enteros
class IntegerLessonScreenInteractive extends StatelessWidget {
  const IntegerLessonScreenInteractive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LessonScreenBaseInteractive(
      title: 'Números Enteros',
      icon: Icons.exposure_zero,
      titleGradient: const LinearGradient(
        colors: [
          Color(0xFF6200EA), // Violeta
          Color(0xFF3949AB), // Azul índigo
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      totalSteps: 3,
      steps: const [
        // Paso 1: ¿Qué son los números enteros? - Interactivo
        WhatAreIntegersStepInteractive(),
        // Paso 2: Recta numérica - Interactivo
        NumberLineStepInteractive(),
        // Paso 3: Aplicaciones en la vida cotidiana - Interactivo
        ApplicationsStepInteractive(),
      ],
      completionRoute: AppRoutes.integerRescueGame,
      completionPoints: 30,
      completionMessage: '¡Felicidades! Has completado la lección sobre números enteros.',
      // Imagen de fondo para la lección
      backgroundAsset: 'assets/images/math_bg.png',
      // Colores personalizados para los botones de navegación
      nextButtonColor: const Color(0xFF00C853), // Verde
      previousButtonColor: const Color(0xFF3F51B5), // Azul índigo
    );
  }
}