// lib/widgets/lessons/ai_help_dialog.dart
import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../theme/app_colors.dart';
import '../../services/gemini_service.dart';

class AIHelpDialog extends StatefulWidget {
  final Exercise exercise;
  final String lessonTitle;
  final VoidCallback onDismiss;

  const AIHelpDialog({
    Key? key,
    required this.exercise,
    required this.lessonTitle,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<AIHelpDialog> createState() => _AIHelpDialogState();
}

class _AIHelpDialogState extends State<AIHelpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _response = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _getAIHelp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAIHelp() async {
    try {
      final helpQuery = _buildHelpQuery();
      final response = await GeminiService.getErrorExplanation(
        concept: 'números enteros',
        userAnswer: 'ayuda',
        correctAnswer: helpQuery,
        lessonContext: widget.lessonTitle,
      );
      
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = GeminiService.getOfflineExplanation(
          concept: 'enteros',
          userAnswer: 'ayuda',
          correctAnswer: widget.exercise.question,
        );
        _isLoading = false;
      });
    }
  }

  String _buildHelpQuery() {
    if (widget.exercise.type == 1) {
      return 'Explica cómo resolver esta pregunta de selección múltiple sobre números enteros: ${widget.exercise.question}';
    } else {
      return 'Explica cómo ordenar estos elementos de menor a mayor: ${widget.exercise.question}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🤖 Ayuda con IA',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Pregunta del ejercicio
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  widget.exercise.question,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Respuesta de la IA
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.info),
                            const SizedBox(height: 12),
                            Text(
                              'Generando explicación...',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _response,
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botón de cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '¡Entendido!',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}