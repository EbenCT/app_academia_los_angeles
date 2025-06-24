// lib/screens/teacher/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/animations/fade_animation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar personalizada
            _buildAppBar(),
            
            // Contenido principal
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning,
            AppColors.warning.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Alertas de Estudiantes',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.mark_email_read, color: Colors.white),
                onPressed: provider.hasUnreadNotifications ? () {
                  provider.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas las notificaciones marcadas como leídas'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(
            message: 'Cargando alertas...',
            useAstronaut: true,
          );
        }

        if (provider.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.warning,
          onRefresh: () => provider.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de alertas
                _buildSummaryCard(provider),
                const SizedBox(height: 20),
                
                // Lista de notificaciones
                const Text(
                  'Alertas Recientes',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                ...provider.notifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final notification = entry.value;
                  
                  return FadeAnimation(
                    delay: Duration(milliseconds: 100 * (index + 1)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNotificationCard(notification, provider),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 100), // Espacio extra al final
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(NotificationProvider provider) {
    final unreadCount = provider.unreadCount;
    final lowPerformanceCount = provider.getNotificationsByType(NotificationType.lowPerformance).length;
    final highErrorsCount = provider.getNotificationsByType(NotificationType.highErrors).length;
    final inactiveCount = provider.getNotificationsByType(NotificationType.inactive).length;

    return FadeAnimation(
      delay: const Duration(milliseconds: 200),
      child: AppCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.1),
                AppColors.error.withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Resumen de Alertas',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Sin Leer',
                      '$unreadCount',
                      AppColors.error,
                      Icons.mark_email_unread,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Bajo Rendimiento',
                      '$lowPerformanceCount',
                      AppColors.warning,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Muchos Errores',
                      '$highErrorsCount',
                      AppColors.error,
                      Icons.error_outline,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Inactivos',
                      '$inactiveCount',
                      AppColors.info,
                      Icons.pause_circle_outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    final typeColor = _getNotificationColor(notification.type);
    final typeIcon = _getNotificationIcon(notification.type);
    
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          provider.markAsRead(notification.id);
        }
        _showNotificationDetail(notification);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? Colors.grey.shade300 
                : typeColor.withOpacity(0.5),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la notificación
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: notification.isRead 
                              ? Colors.grey.shade700 
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        notification.classroom,
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Mensaje principal
            Text(
              notification.message,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 13,
                color: notification.isRead 
                    ? Colors.grey.shade600 
                    : AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Áreas débiles (muestra máximo 2)
            if (notification.weakAreas.isNotEmpty) ...[
              Text(
                'Áreas a reforzar:',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: notification.weakAreas.take(2).map((area) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 10,
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
              if (notification.weakAreas.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${notification.weakAreas.length - 2} más...',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
            
            const SizedBox(height: 8),
            
            // Timestamp
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Excelente!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay alertas de estudiantes en riesgo',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle para arrastrar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título del detalle
              Row(
                children: [
                  Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del estudiante
                      _buildDetailSection('Estudiante', notification.studentName),
                      _buildDetailSection('Aula', notification.classroom),
                      _buildDetailSection('Descripción', notification.message),
                      
                      // Áreas débiles
                      const Text(
                        'Áreas a Reforzar:',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...notification.weakAreas.map((area) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(notification.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getNotificationColor(notification.type).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: _getNotificationColor(notification.type),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                area,
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 14,
                                  color: _getNotificationColor(notification.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      
                      const SizedBox(height: 16),
                      
                      // Recomendaciones
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: AppColors.info),
                                const SizedBox(width: 8),
                                const Text(
                                  'Recomendaciones:',
                                  style: TextStyle(
                                    fontFamily: 'Comic Sans MS',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Programar sesión de refuerzo individual\n'
                              '• Asignar ejercicios adicionales en áreas débiles\n'
                              '• Contactar a los padres para apoyo en casa\n'
                              '• Evaluar ajuste en metodología de enseñanza',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.lowPerformance:
        return AppColors.warning;
      case NotificationType.highErrors:
        return AppColors.error;
      case NotificationType.inactive:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.lowPerformance:
        return Icons.trending_down;
      case NotificationType.highErrors:
        return Icons.error_outline;
      case NotificationType.inactive:
        return Icons.pause_circle_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}