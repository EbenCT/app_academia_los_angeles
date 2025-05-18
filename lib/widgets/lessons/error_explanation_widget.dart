import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/gemini_service.dart';

class ErrorExplanationWidget extends StatefulWidget {
  final String concept;
  final String userAnswer;
  final String correctAnswer;
  final String lessonContext;
  final VoidCallback onDismiss;
  final bool useAnimation;

  const ErrorExplanationWidget({
    Key? key,
    required this.concept,
    required this.userAnswer,
    required this.correctAnswer,
    required this.lessonContext,
    required this.onDismiss,
    this.useAnimation = true,
  }) : super(key: key);

  @override
  State<ErrorExplanationWidget> createState() => _ErrorExplanationWidgetState();
}

class _ErrorExplanationWidgetState extends State<ErrorExplanationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _explanation = "Cargando explicación...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.useAnimation) {
      _animationController.forward();
    }

    _getExplanation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getExplanation() async {
    try {
      final explanation = await GeminiService.getErrorExplanation(
        concept: widget.concept,
        userAnswer: widget.userAnswer,
        correctAnswer: widget.correctAnswer,
        lessonContext: widget.lessonContext,
      );
      
      setState(() {
        _explanation = explanation;
        _isLoading = false;
      });
    } catch (e) {
      // Usar una explicación offline en caso de error
      setState(() {
        _explanation = GeminiService.getOfflineExplanation(
          concept: widget.concept,
          userAnswer: widget.userAnswer,
          correctAnswer: widget.correctAnswer,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return widget.useAnimation
        ? ScaleTransition(
            scale: _animation,
            child: _buildExplanationCard(isDarkMode),
          )
        : _buildExplanationCard(isDarkMode);
  }

  Widget _buildExplanationCard(bool isDarkMode) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Entendamos esto juntos",
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _explanation,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "¡Entendido!",
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}