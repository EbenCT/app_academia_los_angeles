// lib/services/exercise_validator.dart
import '../models/lesson_models.dart';

class ExerciseValidator {
  /// Verifica si un ejercicio de tipo 1 (selección múltiple) es correcto
  static bool validateMultipleChoice(Exercise exercise, List<int> selectedIds) {
    final correctOptions = exercise.options.where((opt) => opt.isCorrect).map((opt) => opt.id).toList();
    
    if (selectedIds.length != correctOptions.length) return false;
    
    for (final correctId in correctOptions) {
      if (!selectedIds.contains(correctId)) return false;
    }
    return true;
  }

  /// Verifica si un ejercicio de tipo 2 (ordenamiento) es correcto
  static bool validateOrdering(Exercise exercise, List<int> orderedIds) {
    final correctOrder = exercise.options.toList()..sort((a, b) => a.index.compareTo(b.index));
    
    if (orderedIds.length != correctOrder.length) return false;
    
    for (int i = 0; i < orderedIds.length; i++) {
      if (orderedIds[i] != correctOrder[i].id) return false;
    }
    return true;
  }

  /// Verifica si un ejercicio es correcto basado en su tipo
  static bool isExerciseCorrect(Exercise exercise, Map<int, List<int>> selectedAnswers, Map<int, List<int>> orderedAnswers) {
    if (exercise.type == 1) {
      final selected = selectedAnswers[exercise.id] ?? [];
      return validateMultipleChoice(exercise, selected);
    } else if (exercise.type == 2) {
      final ordered = orderedAnswers[exercise.id] ?? [];
      return validateOrdering(exercise, ordered);
    }
    return false;
  }

  /// Convierte las respuestas del usuario a texto legible
  static String getUserAnswerText(Exercise exercise, Map<int, List<int>> selectedAnswers, Map<int, List<int>> orderedAnswers) {
    if (exercise.type == 1) {
      final selected = selectedAnswers[exercise.id] ?? [];
      final selectedOptions = exercise.options.where((opt) => selected.contains(opt.id));
      return selectedOptions.map((opt) => opt.text).join(', ');
    } else if (exercise.type == 2) {
      final ordered = orderedAnswers[exercise.id] ?? [];
      final orderedOptions = ordered.map((id) => 
        exercise.options.firstWhere((opt) => opt.id == id).text
      );
      return orderedOptions.join(' → ');
    }
    return '';
  }

  /// Obtiene la respuesta correcta en texto legible
  static String getCorrectAnswerText(Exercise exercise) {
    if (exercise.type == 1) {
      final correctOptions = exercise.options.where((opt) => opt.isCorrect);
      return correctOptions.map((opt) => opt.text).join(', ');
    } else if (exercise.type == 2) {
      final correctOrder = exercise.options.toList()..sort((a, b) => a.index.compareTo(b.index));
      return correctOrder.map((opt) => opt.text).join(' → ');
    }
    return '';
  }
}