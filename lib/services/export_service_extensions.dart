// lib/services/export_service_extensions.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student_tracking_model.dart';
import '../theme/app_colors.dart';

/// Extensiones del ExportService para manejo de datos individuales de estudiantes
class ExportServiceExtensions {
  
  /// Exportar datos de un estudiante específico a PDF
  static Future<void> exportStudentToPDF({
    required StudentTrackingModel student,
    required BuildContext context,
  }) async {
    try {
      await _requestStoragePermission();
      
      final pdf = pw.Document();
      
      // Página principal con información del estudiante
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildStudentPDFHeader(student),
              pw.SizedBox(height: 20),
              _buildStudentBasicInfo(student),
              pw.SizedBox(height: 20),
              _buildStudentMetrics(student),
              pw.SizedBox(height: 20),
              _buildStudentSubjectProgress(student),
              pw.SizedBox(height: 20),
              _buildStudentRecommendations(student),
            ];
          },
        ),
      );
      
      final now = DateTime.now();
      final dateStr = '${now.day}_${now.month}_${now.year}';
      final fileName = '${student.fullName.replaceAll(' ', '_')}_seguimiento_$dateStr.pdf';
      
      await _savePDFAndShare(pdf, fileName, context);
      
    } catch (e) {
      _showError(context, 'Error al generar PDF del estudiante: $e');
    }
  }

  /// Exportar datos de un estudiante específico a Excel
  static Future<void> exportStudentToExcel({
    required StudentTrackingModel student,
    required BuildContext context,
  }) async {
    try {
      await _requestStoragePermission();
      
      var excel = Excel.createExcel();
      
      // Información básica del estudiante
      _createStudentInfoSheet(excel, student);
      
      // Métricas detalladas
      _createStudentMetricsSheet(excel, student);
      
      // Progreso por materias
      _createStudentSubjectsSheet(excel, student);
      
      // Recomendaciones
      _createStudentRecommendationsSheet(excel, student);
      
      // Eliminar hoja por defecto
      excel.delete('Sheet1');
      
      final now = DateTime.now();
      final dateStr = '${now.day}_${now.month}_${now.year}';
      final fileName = '${student.fullName.replaceAll(' ', '_')}_seguimiento_$dateStr.xlsx';
      
      await _saveExcelAndShare(excel, fileName, context);
      
    } catch (e) {
      _showError(context, 'Error al generar Excel del estudiante: $e');
    }
  }

  // ============ MÉTODOS AUXILIARES PARA PERMISOS Y GUARDADO ============
  
  static Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        throw Exception('Permisos de almacenamiento denegados');
      }
    }
  }

  static Future<void> _savePDFAndShare(pw.Document pdf, String fileName, BuildContext context) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte generado por Colegio Los Ángeles',
      subject: 'Reporte Académico Individual',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generado y compartido exitosamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  static Future<void> _saveExcelAndShare(Excel excel, String fileName, BuildContext context) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte generado por Colegio Los Ángeles',
        subject: 'Reporte Académico Individual Excel',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel generado y compartido exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 5),
      ),
    );
  }

  // ============ MÉTODOS PARA PDF ============
  
  static pw.Widget _buildStudentPDFHeader(StudentTrackingModel student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Colegio Los Ángeles',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#6200EA'),
                  ),
                ),
                pw.Text(
                  'Reporte Individual de Seguimiento',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Fecha: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Estudiante: ${student.fullName}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          width: double.infinity,
          height: 2,
          color: PdfColor.fromHex('#6200EA'),
        ),
      ],
    );
  }

  static pw.Widget _buildStudentBasicInfo(StudentTrackingModel student) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Información del Estudiante',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nombre: ${student.fullName}', style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text('Email: ${student.email}', style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text('Estado: ${_getStatusTextForPDF(student.estado)}', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nivel Actual: ${student.nivelActual}', style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text('Experiencia: ${student.xp} XP', style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text('Última Actividad: ${student.ultimaActividad}', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentMetrics(StudentTrackingModel student) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Métricas de Rendimiento',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Métrica', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Evaluación', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              _buildMetricRow('Avance General', '${student.avance}%', _getProgressEvaluation(student.avance)),
              _buildMetricRow('Tiempo Dedicado', '${student.tiempoDedicado} minutos', _getTimeEvaluation(student.tiempoDedicado)),
              _buildMetricRow('Porcentaje de Aciertos', '${student.porcentajeAciertos}%', _getAccuracyEvaluation(student.porcentajeAciertos)),
              _buildMetricRow('Porcentaje de Errores', '${student.porcentajeErrores}%', _getErrorEvaluation(student.porcentajeErrores)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildMetricRow(String metric, String value, String evaluation) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(metric),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(evaluation),
        ),
      ],
    );
  }

  static pw.Widget _buildStudentSubjectProgress(StudentTrackingModel student) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Progreso por Materias',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Materia', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Progreso', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Tiempo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Estado', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...student.progressoMaterias.map((subject) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(subject.name),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${subject.progress}%'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${subject.timeSpent}m'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(_getSubjectStatus(subject.progress)),
                  ),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentRecommendations(StudentTrackingModel student) {
    final recommendations = _generateRecommendations(student);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recomendaciones Pedagógicas',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          ...recommendations.map((rec) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(fontSize: 14)),
                pw.Expanded(
                  child: pw.Text(rec, style: pw.TextStyle(fontSize: 14)),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ============ MÉTODOS PARA EXCEL ============
  
  static void _createStudentInfoSheet(Excel excel, StudentTrackingModel student) {
    var sheet = excel['Información Personal'];
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('INFORMACIÓN DEL ESTUDIANTE');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Nombre Completo:');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(student.fullName);
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Email:');
    sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue(student.email);
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Estado:');
    sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue(_getStatusTextForPDF(student.estado));
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Nivel Actual:');
    sheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(student.nivelActual);
    
    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Experiencia (XP):');
    sheet.cell(CellIndex.indexByString('B7')).value = IntCellValue(student.xp);
    
    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Última Actividad:');
    sheet.cell(CellIndex.indexByString('B8')).value = TextCellValue(student.ultimaActividad);
    
    sheet.cell(CellIndex.indexByString('A10')).value = TextCellValue('Fecha del Reporte:');
    sheet.cell(CellIndex.indexByString('B10')).value = TextCellValue(DateTime.now().toString().split(' ')[0]);
  }

  static void _createStudentMetricsSheet(Excel excel, StudentTrackingModel student) {
    var sheet = excel['Métricas de Rendimiento'];
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('MÉTRICAS DE RENDIMIENTO');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));
    
    // Headers
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Métrica');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue('Valor');
    sheet.cell(CellIndex.indexByString('C3')).value = TextCellValue('Porcentaje');
    sheet.cell(CellIndex.indexByString('D3')).value = TextCellValue('Evaluación');
    
    // Datos
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Avance General');
    sheet.cell(CellIndex.indexByString('B4')).value = IntCellValue(student.avance);
    sheet.cell(CellIndex.indexByString('C4')).value = TextCellValue('${student.avance}%');
    sheet.cell(CellIndex.indexByString('D4')).value = TextCellValue(_getProgressEvaluation(student.avance));
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Tiempo Dedicado');
    sheet.cell(CellIndex.indexByString('B5')).value = IntCellValue(student.tiempoDedicado);
    sheet.cell(CellIndex.indexByString('C5')).value = TextCellValue('${student.tiempoDedicado} min');
    sheet.cell(CellIndex.indexByString('D5')).value = TextCellValue(_getTimeEvaluation(student.tiempoDedicado));
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Aciertos');
    sheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(student.porcentajeAciertos);
    sheet.cell(CellIndex.indexByString('C6')).value = TextCellValue('${student.porcentajeAciertos}%');
    sheet.cell(CellIndex.indexByString('D6')).value = TextCellValue(_getAccuracyEvaluation(student.porcentajeAciertos));
    
    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Errores');
    sheet.cell(CellIndex.indexByString('B7')).value = IntCellValue(student.porcentajeErrores);
    sheet.cell(CellIndex.indexByString('C7')).value = TextCellValue('${student.porcentajeErrores}%');
    sheet.cell(CellIndex.indexByString('D7')).value = TextCellValue(_getErrorEvaluation(student.porcentajeErrores));
  }

  static void _createStudentSubjectsSheet(Excel excel, StudentTrackingModel student) {
    var sheet = excel['Progreso por Materias'];
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('PROGRESO POR MATERIAS');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));
    
    // Headers
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Materia');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue('Progreso %');
    sheet.cell(CellIndex.indexByString('C3')).value = TextCellValue('Tiempo (min)');
    sheet.cell(CellIndex.indexByString('D3')).value = TextCellValue('Estado');
    
    // Datos
    for (int i = 0; i < student.progressoMaterias.length; i++) {
      final subject = student.progressoMaterias[i];
      final row = i + 4;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(subject.name);
      sheet.cell(CellIndex.indexByString('B$row')).value = IntCellValue(subject.progress);
      sheet.cell(CellIndex.indexByString('C$row')).value = IntCellValue(subject.timeSpent);
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(_getSubjectStatus(subject.progress));
    }
  }

  static void _createStudentRecommendationsSheet(Excel excel, StudentTrackingModel student) {
    var sheet = excel['Recomendaciones'];
    final recommendations = _generateRecommendations(student);
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('RECOMENDACIONES PEDAGÓGICAS');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));
    
    for (int i = 0; i < recommendations.length; i++) {
      final row = i + 3;
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue('${i + 1}.');
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(recommendations[i]);
    }
  }

  // ============ MÉTODOS AUXILIARES ============
  
  static String _getStatusTextForPDF(String status) {
    switch (status) {
      case 'activo': return 'Activo';
      case 'en_progreso': return 'En Progreso';
      default: return 'Inactivo';
    }
  }

  static String _getProgressEvaluation(int progress) {
    if (progress >= 80) return 'Excelente';
    if (progress >= 60) return 'Bueno';
    if (progress >= 40) return 'Regular';
    return 'Necesita atención';
  }

  static String _getTimeEvaluation(int timeSpent) {
    if (timeSpent >= 200) return 'Muy dedicado';
    if (timeSpent >= 120) return 'Dedicado';
    if (timeSpent >= 60) return 'Moderado';
    return 'Poco tiempo';
  }

  static String _getAccuracyEvaluation(int accuracy) {
    if (accuracy >= 90) return 'Excelente';
    if (accuracy >= 80) return 'Muy bueno';
    if (accuracy >= 70) return 'Bueno';
    if (accuracy >= 60) return 'Regular';
    return 'Necesita mejora';
  }

  static String _getErrorEvaluation(int errors) {
    if (errors <= 10) return 'Muy bajo';
    if (errors <= 20) return 'Bajo';
    if (errors <= 30) return 'Moderado';
    return 'Alto - requiere atención';
  }

  static String _getSubjectStatus(int progress) {
    if (progress >= 75) return 'Avanzado';
    if (progress >= 50) return 'En progreso';
    if (progress >= 25) return 'Iniciando';
    return 'Sin iniciar';
  }

  static List<String> _generateRecommendations(StudentTrackingModel student) {
    List<String> recommendations = [];

    // Basado en el avance general
    if (student.avance < 40) {
      recommendations.add('Se recomienda reforzar las bases fundamentales y brindar apoyo adicional.');
    } else if (student.avance >= 80) {
      recommendations.add('Excelente progreso. Considerar actividades de enriquecimiento o retos adicionales.');
    }

    // Basado en el tiempo dedicado
    if (student.tiempoDedicado < 60) {
      recommendations.add('Aumentar el tiempo de estudio diario para mejorar el rendimiento.');
    } else if (student.tiempoDedicado > 200) {
      recommendations.add('Optimizar el tiempo de estudio para evitar fatiga y mantener la motivación.');
    }

    // Basado en aciertos/errores
    if (student.porcentajeAciertos < 70) {
      recommendations.add('Implementar estrategias de refuerzo para mejorar la comprensión de conceptos.');
    }

    if (student.porcentajeErrores > 30) {
      recommendations.add('Analizar los tipos de errores más frecuentes y trabajar en esas áreas específicas.');
    }

    // Basado en el estado
    if (student.estado == 'inactivo') {
      recommendations.add('Motivar la participación activa y establecer metas alcanzables a corto plazo.');
    }

    // Recomendaciones por materia
    for (final subject in student.progressoMaterias) {
      if (subject.progress < 30) {
        recommendations.add('Reforzar específicamente ${subject.name} con ejercicios adicionales.');
      }
    }

    // Si no hay recomendaciones específicas, agregar una general
    if (recommendations.isEmpty) {
      recommendations.add('Continuar con el buen trabajo y mantener la consistencia en el estudio.');
    }

    return recommendations;
  }
}