import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/classroom_model.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';
import '../common/app_card.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ClassroomCardWidget extends StatelessWidget {
  final ClassroomModel classroom;
  final VoidCallback onTap;
  
  const ClassroomCardWidget({
    super.key,
    required this.classroom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BounceAnimation(
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          hasShadow: true,
          borderColor: AppColors.secondary.withOpacity(0.3),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildHeader(context, isDarkMode),
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.name,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Curso: ${classroom.courseName}',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildStudentCountBadge(),
        ],
      ),
    );
  }
  
  Widget _buildStudentCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: AppColors.secondary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${classroom.studentsCount}',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (classroom.description != null && classroom.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                classroom.description!,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.qr_code,
                label: 'Mostrar QR',
                color: AppColors.primary,
                onTap: () => _showQRCode(context, classroom),
              ),
              
              _buildActionButton(
                icon: Icons.share,
                label: 'Compartir',
                color: AppColors.secondary,
                onTap: () => _shareClassroomCode(context, classroom),
              ),
_buildActionButton(
                icon: Icons.people,
                label: 'Estudiantes (${classroom.studentsCount})',
                color: AppColors.accent,
                onTap: () => _viewStudents(context, classroom),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar estudiantes
  void _viewStudents(BuildContext context, ClassroomModel classroom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Función en desarrollo: Ver estudiantes del aula ${classroom.name}',
          style: TextStyle(fontFamily: 'Comic Sans MS'),
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Compartir código
  void _shareClassroomCode(BuildContext context, ClassroomModel classroom) {
    Share.share(
      '¡Únete a mi aula "${classroom.name}" en Academia Los Ángeles! Usa el código: ${classroom.id}',
      subject: 'Invitación a aula - Academia Los Ángeles',
    );
  }

  // Mostrar código QR
  void _showQRCode(BuildContext context, ClassroomModel classroom) {
    // Clave global para capturar el widget QR
    final GlobalKey qrKey = GlobalKey();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildQRDialog(context, classroom, qrKey);
      },
    );
  }
  
  Widget _buildQRDialog(BuildContext context, ClassroomModel classroom, GlobalKey qrKey) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Escanea para unirte!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aula: ${classroom.name}',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            // Container con clave para capturar el QR
            RepaintBoundary(
              key: qrKey,
              child: _buildQRContent(classroom),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _captureAndShareQR(context, qrKey),
                  icon: Icon(Icons.qr_code),
                  label: Text('Compartir QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              label: Text('Cerrar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRContent(ClassroomModel classroom) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: classroom.id.toString(),
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            errorStateBuilder: (context, error) {
              return Center(
                child: Text(
                  'Error al generar QR',
                  style: TextStyle(fontFamily: 'Comic Sans MS'),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Aula: ${classroom.name}',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          Text(
            'Academia Los Ángeles',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShareQR(BuildContext context, GlobalKey key) async {
    try {
      // Mostrar indicador de carga
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Preparando imagen para compartir...',
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: const Duration(seconds: 2),
        ),
      );

      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Guardar temporalmente la imagen
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_code.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        // Compartir la imagen
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '¡Únete a mi aula en Academia Los Ángeles!',
          subject: 'Código QR - Academia Los Ángeles',
        );
      }
    } catch (e) {
      print('Error al capturar y compartir QR: $e');
      
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo compartir el código QR: $e',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}