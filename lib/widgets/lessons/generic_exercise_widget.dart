// lib/widgets/lessons/generic_exercise_widget.dart

import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';

class GenericExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final Function(bool wasCorrect) onCompleted;

  const GenericExerciseWidget({
    super.key,
    required this.exercise,
    required this.onCompleted,
  });

  @override
  State<GenericExerciseWidget> createState() => _GenericExerciseWidgetState();
}

class _GenericExerciseWidgetState extends State<GenericExerciseWidget> {
  // Estados para ejercicios tipo 1 (respuesta correcta)
  Set<int> _selectedOptions = {};
  
  // Estados para ejercicios tipo 2 (ordenar)
  List<ExerciseOption> _orderedOptions = [];
  
  bool _hasAnswered = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeExercise();
  }

  void _initializeExercise() {
    if (widget.exercise.type == 2) {
      // Para ejercicios de ordenamiento, mezclar las opciones
      _orderedOptions = List.from(widget.exercise.options);
      _orderedOptions.shuffle();
    }
  }

  void _selectOption(int optionId) {
    if (_hasAnswered) return;

    setState(() {
      if (_selectedOptions.contains(optionId)) {
        _selectedOptions.remove(optionId);
      } else {
        _selectedOptions.add(optionId);
      }
    });
  }

  void _reorderOption(int oldIndex, int newIndex) {
    if (_hasAnswered) return;
    
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final option = _orderedOptions.removeAt(oldIndex);
      _orderedOptions.insert(newIndex, option);
    });
  }

  void _checkAnswer() {
    if (_hasAnswered) return;

    bool correct = false;
    String feedback = '';

    if (widget.exercise.type == 1) {
      // Verificar respuestas correctas tipo 1
      correct = _checkType1Answer();
      feedback = correct 
          ? '¡Excelente! Has seleccionado todas las respuestas correctas.'
          : 'Algunas respuestas no son correctas. Revisa tu selección.';
    } else if (widget.exercise.type == 2) {
      // Verificar orden correcto tipo 2
      correct = _checkType2Answer();
      feedback = correct 
          ? '¡Perfecto! Has ordenado correctamente todos los elementos.'
          : 'El orden no es correcto. Intenta de nuevo.';
    }

    setState(() {
      _hasAnswered = true;
      _showFeedback = true;
      _isCorrect = correct;
      _feedbackMessage = feedback;
    });

    // Llamar al callback después de un breve delay
    Future.delayed(Duration(seconds: 2), () {
      widget.onCompleted(correct);
    });
  }

  bool _checkType1Answer() {
    // Obtener todas las opciones correctas
    final correctOptions = widget.exercise.options
        .where((option) => option.isCorrect)
        .map((option) => option.id)
        .toSet();
    
    // Verificar que se hayan seleccionado exactamente las correctas
    return _selectedOptions.length == correctOptions.length &&
           _selectedOptions.containsAll(correctOptions);
  }

  bool _checkType2Answer() {
    // Verificar que el orden sea correcto según el índice
    for (int i = 0; i < _orderedOptions.length; i++) {
      if (_orderedOptions[i].index != i + 1) {
        return false;
      }
    }
    return true;
  }

  void _resetExercise() {
    setState(() {
      _selectedOptions.clear();
      _hasAnswered = false;
      _showFeedback = false;
      _isCorrect = false;
      _feedbackMessage = '';
      
      if (widget.exercise.type == 2) {
        _orderedOptions.shuffle();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Información del ejercicio
          _buildExerciseHeader(),
          
          SizedBox(height: 20),
          
          // Pregunta
          _buildQuestion(),
          
          SizedBox(height: 30),
          
          // Contenido según el tipo
          if (widget.exercise.type == 1)
            _buildType1Content()
          else if (widget.exercise.type == 2)
            _buildType2Content(),
          
          SizedBox(height: 30),
          
          // Feedback
          if (_showFeedback) _buildFeedback(),
          
          SizedBox(height: 20),
          
          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.exercise.type == 1 ? Icons.quiz : Icons.sort,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.type == 1 ? 'Selección múltiple' : 'Ordenamiento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  'Dificultad: ${widget.exercise.severity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 16, color: AppColors.warning),
                SizedBox(width: 4),
                Text(
                  '${widget.exercise.coins}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.exercise.question,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildType1Content() {
    return FadeAnimation(
      delay: Duration(milliseconds: 400),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: widget.exercise.options.map((option) {
          final isSelected = _selectedOptions.contains(option.id);
          
          return GestureDetector(
            onTap: () => _selectOption(option.id),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _getOptionColor(option, isSelected),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _getOptionBorderColor(option, isSelected),
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Text(
                option.text,
                style: TextStyle(
                  color: _getOptionTextColor(option, isSelected),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildType2Content() {
    return FadeAnimation(
      delay: Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          onReorder: _reorderOption,
          itemCount: _orderedOptions.length,
          itemBuilder: (context, index) {
            final option = _orderedOptions[index];
            
            return Container(
              key: ValueKey(option.id),
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.drag_handle,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return FadeAnimation(
      delay: Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isCorrect ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isCorrect ? AppColors.success : AppColors.error,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.error,
              color: _isCorrect ? AppColors.success : AppColors.error,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _feedbackMessage,
                style: TextStyle(
                  color: _isCorrect ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_hasAnswered) {
      // Botón para verificar respuesta
      bool canCheck = widget.exercise.type == 1 ? _selectedOptions.isNotEmpty : true;
      
      return ElevatedButton.icon(
        onPressed: canCheck ? _checkAnswer : null,
        icon: Icon(Icons.check),
        label: Text('Verificar respuesta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 3,
        ),
      );
    } else if (!_isCorrect) {
      // Botón para intentar de nuevo
      return ElevatedButton.icon(
        onPressed: _resetExercise,
        icon: Icon(Icons.refresh),
        label: Text('Intentar de nuevo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 3,
        ),
      );
    } else {
      // Mensaje de éxito
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              '¡Continúa con el siguiente paso!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getOptionColor(ExerciseOption option, bool isSelected) {
    if (!_hasAnswered) {
      return isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white;
    }
    
    // Mostrar feedback después de responder
    if (option.isCorrect) {
      return AppColors.success.withOpacity(0.1);
    } else if (isSelected) {
      return AppColors.error.withOpacity(0.1);
    }
    
    return Colors.white;
  }

  Color _getOptionBorderColor(ExerciseOption option, bool isSelected) {
    if (!_hasAnswered) {
      return isSelected ? AppColors.primary : Colors.grey[300]!;
    }
    
    if (option.isCorrect) {
      return AppColors.success;
    } else if (isSelected) {
      return AppColors.error;
    }
    
    return Colors.grey[300]!;
  }

  Color _getOptionTextColor(ExerciseOption option, bool isSelected) {
    if (!_hasAnswered) {
      return isSelected ? AppColors.primary : AppColors.textPrimary;
    }
    
    if (option.isCorrect) {
      return AppColors.success;
    } else if (isSelected) {
      return AppColors.error;
    }
    
    return AppColors.textPrimary;
  }
}