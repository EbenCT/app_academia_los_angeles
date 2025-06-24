// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  bool get hasUnreadNotifications => unreadCount > 0;

  // Constructor - cargar notificaciones automáticamente
  NotificationProvider() {
    loadNotifications();
  }

  // Cargar notificaciones (simuladas)
  Future<void> loadNotifications() async {
    _setLoading(true);
    
    // Simular delay de carga
    await Future.delayed(const Duration(milliseconds: 500));
    
    _notifications = NotificationGenerator.generateStaticNotifications();
    
    _setLoading(false);
  }

  // Marcar notificación como leída
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Marcar todas como leídas
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // Refrescar notificaciones
  Future<void> refresh() async {
    await loadNotifications();
  }

  // Obtener notificaciones por tipo
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Obtener estudiantes únicos con alertas
  List<String> getStudentsWithAlerts() {
    return _notifications.map((n) => n.studentName).toSet().toList();
  }

  // Obtener alertas de un estudiante específico
  List<NotificationModel> getAlertsForStudent(String studentName) {
    return _notifications.where((n) => n.studentName == studentName).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}