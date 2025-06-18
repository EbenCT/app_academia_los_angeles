// lib/widgets/transition/subject_to_topics_transition.dart

import 'package:flutter/material.dart';
import '../../models/lesson_models.dart';
import '../../services/lesson_api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../screens/courses/generic_topic_lessons_screen.dart';

/// Widget que maneja la transición del sistema antiguo al nuevo
/// Convierte una "materia" en "temas" y navega apropiadamente
class SubjectToTopicsTransition {
  
  /// Navega desde una materia a sus temas usando el nuevo sistema genérico
  static Future<void> navigateToSubjectTopics(
    BuildContext context, 
    dynamic oldSubject, // El objeto subject de tu sistema actual
  ) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: LoadingIndicator(
              message: 'Cargando temas...',
              useAstronaut: true,
              size: 100,
            ),
          ),
        ),
      );

      // Convertir el subject actual al formato del nuevo sistema
      final subject = Subject(
        id: oldSubject.id,
        code: oldSubject.code ?? '',
        name: oldSubject.name,
        description: oldSubject.description ?? '',
      );

      // Obtener temas del backend
      final topics = await LessonApiService.getTopicsBySubject(subject.id);
      
      // Cerrar loading
      Navigator.pop(context);

      if (topics.isEmpty) {
        // No hay temas, mostrar mensaje
        _showNoTopicsDialog(context, subject.name);
        return;
      }

      if (topics.length == 1) {
        // Solo hay un tema, navegar directamente
        final topic = topics.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenericTopicLessonsScreen(
              topic: topic,
              subject: subject,
            ),
          ),
        );
      } else {
        // Múltiples temas, mostrar selector
        final selectedTopic = await _showTopicSelectorDialog(context, topics);
        if (selectedTopic != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenericTopicLessonsScreen(
                topic: selectedTopic,
                subject: subject,
              ),
            ),
          );
        }
      }

    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.pop(context);
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar temas: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Muestra un diálogo cuando no hay temas disponibles
  static void _showNoTopicsDialog(BuildContext context, String subjectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.info),
            SizedBox(width: 8),
            Text('Sin contenido'),
          ],
        ),
        content: Text(
          'No hay temas disponibles para $subjectName en este momento.\n\n'
          'Pronto habrá contenido nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Muestra un selector cuando hay múltiples temas
  static Future<Topic?> _showTopicSelectorDialog(
    BuildContext context, 
    List<Topic> topics,
  ) async {
    return showDialog<Topic>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.topic, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Selecciona un tema'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    topic.name,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${topic.xpReward} XP al completar'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pop(context, topic),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}