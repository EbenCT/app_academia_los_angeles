// lib/screens/game/integer_lesson_screen.dart
import 'package:flutter/material.dart';
import '../../config/routes.dart';
import 'lesson_screen_base.dart';
import 'integer_lesson_steps.dart';

/// Pantalla principal para la lección sobre números enteros
class IntegerLessonScreen extends StatelessWidget {
  const IntegerLessonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LessonScreenBase(
      title: 'Números Enteros',
      totalSteps: 3,
      steps: const [
        // Paso 1: ¿Qué son los números enteros?
        WhatAreIntegersStep(),
        
        // Paso 2: Recta numérica
        NumberLineStep(),
        
        // Paso 3: Aplicaciones en la vida cotidiana
        ApplicationsStep(),
      ],
      completionRoute: AppRoutes.integerRescueGame,
      completionPoints: 30,
      completionMessage: '¡Felicidades! Has completado la lección sobre números enteros.',
    );
  }
}