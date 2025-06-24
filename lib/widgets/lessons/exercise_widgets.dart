// lib/widgets/lessons/exercise_widgets.dart
import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';

class ExerciseWidgets {
  
  /// Widget para ejercicios de selección múltiple (tipo 1)
  static Widget buildMultipleChoiceOptions({
    required Exercise exercise,
    required Map<int, List<int>> selectedAnswers,
    required Function(int exerciseId, int optionId, bool isSelected) onOptionSelected,
    required bool isDisabled,
  }) {
    final selected = selectedAnswers[exercise.id] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la(s) respuesta(s) correcta(s):',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...exercise.options.map((option) {
          final isSelected = selected.contains(option.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: BounceAnimation(
              child: GestureDetector(
                onTap: isDisabled ? null : () {
                  onOptionSelected(exercise.id, option.id, isSelected);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 14,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Widget para ejercicios de ordenamiento (tipo 2)
  static Widget buildOrderingOptions({
    required Exercise exercise,
    required Map<int, List<int>> orderedAnswers,
    required Function(int exerciseId, int optionId) onOptionAdded,
    required Function(int exerciseId, int position) onOptionRemoved,
    required bool isDisabled,
  }) {
    final ordered = orderedAnswers[exercise.id] ?? [];
    
    // Crear lista de opciones disponibles mezcladas
    List<ExerciseOption> shuffledOptions = List<ExerciseOption>.from(exercise.options)..shuffle();
    final availableOptions = shuffledOptions.where((opt) => !ordered.contains(opt.id)).toList();
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 600, // Altura máxima
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ordena las opciones de menor a mayor:',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Área de ordenamiento
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu orden:',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ordered.isEmpty
                      ? Center(
                          child: Text(
                            'Toca las opciones de abajo\npara ordenarlas aquí',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: ordered.asMap().entries.map((entry) {
                              final index = entry.key;
                              final optionId = entry.value;
                              final option = exercise.options.firstWhere((opt) => opt.id == optionId);
                              return _buildOrderedOption(
                                option: option,
                                position: index,
                                onRemove: () => onOptionRemoved(exercise.id, index),
                                isDisabled: isDisabled,
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opciones disponibles
          Text(
            'Opciones disponibles:',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          if (availableOptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todas las opciones han sido colocadas. Presiona "Verificar" para comprobar tu respuesta.',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              constraints: BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableOptions.map((option) {
                    return _buildDraggableOption(
                      option: option,
                      onAdd: () => onOptionAdded(exercise.id, option.id),
                      isDisabled: isDisabled,
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildOrderedOption({
    required ExerciseOption option,
    required int position,
    required VoidCallback onRemove,
    required bool isDisabled,
  }) {
    return BounceAnimation(
      child: GestureDetector(
        onTap: isDisabled ? null : onRemove,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${position + 1}',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDraggableOption({
    required ExerciseOption option,
    required VoidCallback onAdd,
    required bool isDisabled,
  }) {
    return BounceAnimation(
      child: GestureDetector(
        onTap: isDisabled ? null : onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            option.text,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}