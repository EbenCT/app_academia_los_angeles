// lib/screens/terms_conditions_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(fontFamily: 'Comic Sans MS'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TÉRMINOS Y CONDICIONES DE USO',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Academia Los Ángeles - App Educativa',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Text(
              '1. ACEPTACIÓN DE TÉRMINOS',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Al usar esta aplicación, usted acepta estos términos. Si no está de acuerdo, no use el servicio.',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '2. DESCRIPCIÓN DEL SERVICIO',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Academia Los Ángeles es una plataforma educativa gamificada para estudiantes de educación básica y media.',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '3. REGISTRO Y CUENTAS',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '• Los usuarios deben proporcionar información veraz\n• Cada institución educativa debe tener autorización del director\n• Los menores de edad requieren autorización de padres o tutores',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '4. USO ACEPTABLE',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Está prohibido:\n• Usar la plataforma para fines no educativos\n• Compartir credenciales de acceso\n• Intentar hackear o comprometer la seguridad\n• Subir contenido inapropiado o ilegal',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '5. PROPIEDAD INTELECTUAL',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '• El contenido educativo es propiedad de Academia Los Ángeles\n• Los datos de progreso estudiantil pertenecen a la institución educativa\n• Prohibida la reproducción no autorizada del software',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '6. PAGOS Y FACTURACIÓN',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '• Los pagos son anuales por institución\n• No hay reembolsos después de 30 días\n• Los precios pueden cambiar con 60 días de aviso',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '7. LIMITACIÓN DE RESPONSABILIDAD',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Academia Los Ángeles no se hace responsable por:\n• Pérdida de datos por fallas técnicas\n• Interrupciones del servicio por mantenimiento\n• Uso inadecuado por parte de usuarios',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 12),
            
            Text(
              '8. TERMINACIÓN',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Podemos suspender cuentas por violación de términos. Los datos se conservan 30 días para recuperación.',
              style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 14),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}