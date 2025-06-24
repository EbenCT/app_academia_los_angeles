// lib/models/student_tracking_model.dart
class StudentTrackingModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int level;
  final int xp;
  final int avance; // Porcentaje de avance general
  final int tiempoDedicado; // En minutos
  final int porcentajeAciertos;
  final int porcentajeErrores;
  final int nivelActual;
  final String ultimaActividad;
  final String estado; // 'activo', 'inactivo', 'en_progreso'
  final List<SubjectProgressModel> progressoMaterias;

  StudentTrackingModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.level,
    required this.xp,
    required this.avance,
    required this.tiempoDedicado,
    required this.porcentajeAciertos,
    required this.porcentajeErrores,
    required this.nivelActual,
    required this.ultimaActividad,
    required this.estado,
    required this.progressoMaterias,
  });

  String get fullName => '$firstName $lastName';

  factory StudentTrackingModel.fromJson(Map<String, dynamic> json) {
    // Por ahora generamos datos simulados basados en el student
    final id = json['id'] ?? 0;
    final user = json['user'] ?? {};
    final level = json['level'] ?? 1;
    final xp = json['xp'] ?? 0;
    
    // Generar métricas simuladas basadas en los datos reales
    final avance = _calculateProgress(level, xp);
    final tiempoDedicado = _calculateTimeSpent(level);
    final porcentajeAciertos = _calculateSuccessRate(level, xp);
    final porcentajeErrores = 100 - porcentajeAciertos;
    
    return StudentTrackingModel(
      id: id,
      firstName: user['firstName'] ?? 'Estudiante',
      lastName: user['lastName'] ?? 'Sin nombre',
      email: user['email'] ?? '',
      level: level,
      xp: xp,
      avance: avance,
      tiempoDedicado: tiempoDedicado,
      porcentajeAciertos: porcentajeAciertos,
      porcentajeErrores: porcentajeErrores,
      nivelActual: level,
      ultimaActividad: _getLastActivity(),
      estado: _getStudentStatus(level, xp),
      progressoMaterias: _generateSubjectProgress(),
    );
  }

  // Métodos auxiliares para generar datos simulados
  static int _calculateProgress(int level, int xp) {
    return ((level - 1) * 25 + (xp / 100 * 25)).clamp(0, 100).round();
  }

  static int _calculateTimeSpent(int level) {
    return (level * 45 + (level * 10)).clamp(30, 300); // Entre 30 y 300 minutos
  }

  static int _calculateSuccessRate(int level, int xp) {
    final base = 60 + (level * 5);
    final xpBonus = (xp / 1000 * 10).round();
    return (base + xpBonus).clamp(60, 95);
  }

  static String _getLastActivity() {
    final activities = [
      'Hace 2 horas',
      'Hace 1 día',
      'Hace 3 días',
      'Hace 1 semana',
      'Hoy',
      'Ayer',
    ];
    return activities[DateTime.now().millisecond % activities.length];
  }

  static String _getStudentStatus(int level, int xp) {
    if (level >= 3 && xp > 500) return 'activo';
    if (level >= 2) return 'en_progreso';
    return 'inactivo';
  }

  static List<SubjectProgressModel> _generateSubjectProgress() {
    return [
      SubjectProgressModel(name: 'Matemáticas', progress: 75, timeSpent: 120),
      SubjectProgressModel(name: 'Lenguaje', progress: 60, timeSpent: 90),
      SubjectProgressModel(name: 'Ciencias', progress: 45, timeSpent: 60),
    ];
  }
}

class SubjectProgressModel {
  final String name;
  final int progress;
  final int timeSpent;

  SubjectProgressModel({
    required this.name,
    required this.progress,
    required this.timeSpent,
  });
}