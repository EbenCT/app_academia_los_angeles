// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String studentName;
  final String classroom;
  final List<String> weakAreas;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.studentName,
    required this.classroom,
    required this.weakAreas,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.lowPerformance,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      studentName: studentName,
      classroom: classroom,
      weakAreas: weakAreas,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

enum NotificationType {
  lowPerformance,
  highErrors,
  inactive,
}

// Clase para generar notificaciones estáticas
class NotificationGenerator {
  static List<NotificationModel> generateStaticNotifications() {
    final now = DateTime.now();
    
    return [
      NotificationModel(
        id: '1',
        title: 'Estudiante en Riesgo Académico',
        message: 'Carlos López presenta bajo rendimiento en Matemáticas',
        studentName: 'Carlos López',
        classroom: 'Aula Espacial Alpha',
        weakAreas: ['Operaciones básicas', 'Resolución de problemas', 'Cálculo mental'],
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: '2',
        title: 'Alto Porcentaje de Errores',
        message: 'María Rodríguez tiene 65% de errores en Lenguaje',
        studentName: 'María Rodríguez',
        classroom: 'Aula Espacial Beta',
        weakAreas: ['Comprensión lectora', 'Ortografía', 'Redacción'],
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        title: 'Estudiante Inactivo',
        message: 'Diego Martínez no ha completado actividades en 3 días',
        studentName: 'Diego Martínez',
        classroom: 'Aula Espacial Alpha',
        weakAreas: ['Motivación', 'Participación', 'Constancia'],
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.inactive,
      ),
      NotificationModel(
        id: '4',
        title: 'Bajo Avance en el Curso',
        message: 'Sofia Hernández solo tiene 25% de avance general',
        studentName: 'Sofia Hernández',
        classroom: 'Aula Espacial Gamma',
        weakAreas: ['Ciencias Naturales', 'Matemáticas', 'Tiempo de estudio'],
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '5',
        title: 'Dificultades en Múltiples Materias',
        message: 'Pablo Jiménez presenta bajo rendimiento en 3 materias',
        studentName: 'Pablo Jiménez',
        classroom: 'Aula Espacial Beta',
        weakAreas: ['Matemáticas', 'Ciencias', 'Comprensión lectora', 'Análisis'],
        timestamp: now.subtract(const Duration(hours: 6)),
        type: NotificationType.highErrors,
      ),
    ];
  }
}