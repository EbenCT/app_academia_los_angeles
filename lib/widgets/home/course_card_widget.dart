// lib/widgets/home/course_card_widget.dart (con progreso real)
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/lesson_progress_service.dart';
import '../animations/bounce_animation.dart';

class CourseCardWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int subjectId; // Agregamos el ID de la materia

  const CourseCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.subjectId,
  });

  @override
  State<CourseCardWidget> createState() => _CourseCardWidgetState();
}

class _CourseCardWidgetState extends State<CourseCardWidget> {
  double _progress = 0.0;
  int _completed = 0;
  int _total = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progressData = await LessonProgressService.getSubjectProgress(widget.subjectId);
      
      if (mounted) {
        setState(() {
          _progress = progressData['progress'] as double;
          _completed = progressData['completed'] as int;
          _total = progressData['total'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando progreso para ${widget.title}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BounceAnimation(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: widget.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: _buildCardContent(context, isDarkMode),
        ),
      ),
    );
  }
  
  Widget _buildCardContent(BuildContext context, bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Círculo con icono y badge de progreso
        _buildIconCircleWithBadge(),
        const SizedBox(height: 12),
        
        // Título del curso
        _buildTitle(isDarkMode),
        const SizedBox(height: 12),
        
        // Barra de progreso o indicador de carga
        _isLoading ? _buildLoadingIndicator() : _buildProgress(isDarkMode),
      ],
    );
  }
  
  Widget _buildIconCircleWithBadge() {
    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: 36,
          ),
        ),
        // Badge de progreso
        if (!_isLoading && _total > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getProgressColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: _progress >= 1.0
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                    : Text(
                        '${(_progress * 100).round()}',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTitle(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        widget.title,
        style: TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cargando...',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              backgroundColor: widget.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.color.withOpacity(0.5)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgress(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${(_progress * 100).round()}%',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_progress >= 1.0)
                    Icon(
                      Icons.star,
                      color: AppColors.star,
                      size: 14,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: widget.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 5),
          // Mostrar estadísticas detalladas
          if (_total > 0)
            Text(
              '$_completed de $_total lecciones',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 10,
                color: isDarkMode ? Colors.white60 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Sin lecciones disponibles',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (_progress >= 1.0) return AppColors.success;
    if (_progress >= 0.7) return AppColors.star;
    if (_progress >= 0.3) return widget.color;
    return Colors.grey;
  }
}