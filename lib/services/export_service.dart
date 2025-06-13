// lib/services/export_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/classroom_model.dart';
import '../theme/app_colors.dart';

class ExportService {
  /// Exportar datos generales a PDF
  static Future<void> exportGeneralReportToPDF({
    required List<ClassroomModel> classrooms,
    required BuildContext context,
  }) async {
    try {
      // Solicitar permisos
      await _requestStoragePermission();
      
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';
      
      // Calcular métricas generales
      final totalStudents = classrooms.fold<int>(0, (sum, classroom) => sum + classroom.studentsCount);
      final totalClassrooms = classrooms.length;
      final averageProgress = _calculateAverageProgress(classrooms);
      final activeStudents = _calculateActiveStudents(totalStudents);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              _buildPDFHeader(dateStr),
              pw.SizedBox(height: 30),
              
              // Resumen general
              _buildGeneralSummaryPDF(
                totalClassrooms,
                totalStudents,
                averageProgress,
                activeStudents,
              ),
              pw.SizedBox(height: 30),
              
              // Tabla de aulas
              _buildClassroomsTablePDF(classrooms),
              pw.SizedBox(height: 30),
              
              // Métricas detalladas por aula
              ..._buildDetailedMetricsPDF(classrooms),
            ];
          },
        ),
      );

      // Guardar y compartir
      await _savePDFAndShare(pdf, 'reporte_general_${dateStr.replaceAll('/', '_')}.pdf', context);
      
    } catch (e) {
      _showError(context, 'Error al generar PDF: $e');
    }
  }

  /// Exportar datos de un aula específica a PDF
  static Future<void> exportClassroomToPDF({
    required ClassroomModel classroom,
    required BuildContext context,
  }) async {
    try {
      await _requestStoragePermission();
      
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';
      final metrics = _generateClassroomMetrics(classroom);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              _buildPDFHeader(dateStr),
              pw.SizedBox(height: 20),
              
              // Información del aula
              _buildClassroomHeaderPDF(classroom),
              pw.SizedBox(height: 30),
              
              // Métricas del aula
              _buildClassroomMetricsPDF(classroom, metrics),
              pw.SizedBox(height: 30),
              
              // Lista simulada de estudiantes
              _buildStudentsListPDF(classroom),
            ];
          },
        ),
      );

      await _savePDFAndShare(
        pdf, 
        'reporte_${classroom.name.replaceAll(' ', '_')}_${dateStr.replaceAll('/', '_')}.pdf', 
        context
      );
      
    } catch (e) {
      _showError(context, 'Error al generar PDF del aula: $e');
    }
  }

  /// Exportar datos generales a Excel
  static Future<void> exportGeneralReportToExcel({
    required List<ClassroomModel> classrooms,
    required BuildContext context,
  }) async {
    try {
      await _requestStoragePermission();
      
      var excel = Excel.createExcel();
      
      // Hoja de resumen general
      _createGeneralSummarySheet(excel, classrooms);
      
      // Hoja de métricas por aula
      _createClassroomsMetricsSheet(excel, classrooms);
      
      // Hoja de estudiantes simulados
      _createStudentsSheet(excel, classrooms);
      
      // Eliminar hoja por defecto
      excel.delete('Sheet1');
      
      final now = DateTime.now();
      final dateStr = '${now.day}_${now.month}_${now.year}';
      await _saveExcelAndShare(excel, 'reporte_general_$dateStr.xlsx', context);
      
    } catch (e) {
      _showError(context, 'Error al generar Excel: $e');
    }
  }

  /// Exportar datos de un aula específica a Excel
  static Future<void> exportClassroomToExcel({
    required ClassroomModel classroom,
    required BuildContext context,
  }) async {
    try {
      await _requestStoragePermission();
      
      var excel = Excel.createExcel();
      
      // Información del aula
      _createClassroomInfoSheet(excel, classroom);
      
      // Métricas del aula
      _createClassroomMetricsSheet(excel, classroom);
      
      // Lista de estudiantes
      _createClassroomStudentsSheet(excel, classroom);
      
      excel.delete('Sheet1');
      
      final now = DateTime.now();
      final dateStr = '${now.day}_${now.month}_${now.year}';
      await _saveExcelAndShare(
        excel, 
        '${classroom.name.replaceAll(' ', '_')}_$dateStr.xlsx', 
        context
      );
      
    } catch (e) {
      _showError(context, 'Error al generar Excel del aula: $e');
    }
  }

  // ============ MÉTODOS AUXILIARES PARA PDF ============

  static pw.Widget _buildPDFHeader(String date) {
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
                  'Reporte de Seguimiento Académico',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Fecha: $date'),
                pw.Text('Sistema de Gestión Educativa'),
              ],
            ),
          ],
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildGeneralSummaryPDF(
    int totalClassrooms,
    int totalStudents,
    double averageProgress,
    int activeStudents,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen General',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Total de Aulas', isHeader: true),
                _buildTableCell('Total de Estudiantes', isHeader: true),
                _buildTableCell('Progreso Promedio', isHeader: true),
                _buildTableCell('Estudiantes Activos Hoy', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell(totalClassrooms.toString()),
                _buildTableCell(totalStudents.toString()),
                _buildTableCell('${averageProgress.round()}%'),
                _buildTableCell(activeStudents.toString()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClassroomsTablePDF(List<ClassroomModel> classrooms) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Métricas por Aula',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Aula', isHeader: true),
                _buildTableCell('Curso', isHeader: true),
                _buildTableCell('Estudiantes', isHeader: true),
                _buildTableCell('Participación %', isHeader: true),
                _buildTableCell('Rendimiento %', isHeader: true),
                _buildTableCell('Tiempo (hrs)', isHeader: true),
              ],
            ),
            ...classrooms.map((classroom) {
              final metrics = _generateClassroomMetrics(classroom);
              return pw.TableRow(
                children: [
                  _buildTableCell(classroom.name),
                  _buildTableCell(classroom.courseName),
                  _buildTableCell(classroom.studentsCount.toString()),
                  _buildTableCell('${metrics['participation']}%'),
                  _buildTableCell('${metrics['performance']}%'),
                  _buildTableCell('${metrics['timeSpent']}h'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static List<pw.Widget> _buildDetailedMetricsPDF(List<ClassroomModel> classrooms) {
    List<pw.Widget> widgets = [];
    
    widgets.add(
      pw.Text(
        'Análisis Detallado por Aula',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
    );
    widgets.add(pw.SizedBox(height: 15));

    for (final classroom in classrooms) {
      final metrics = _generateClassroomMetrics(classroom);
      
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          margin: const pw.EdgeInsets.only(bottom: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                classroom.name,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('• Curso: ${classroom.courseName}'),
              pw.Text('• Estudiantes: ${classroom.studentsCount}'),
              pw.Text('• Participación: ${metrics['participation']}%'),
              pw.Text('• Rendimiento: ${metrics['performance']}%'),
              pw.Text('• Tiempo promedio semanal: ${metrics['timeSpent']} horas'),
              pw.Text('• Progreso general: ${metrics['overall']}%'),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildClassroomHeaderPDF(ClassroomModel classroom) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E3F2FD'),
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Información del Aula',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Nombre: ${classroom.name}'),
          pw.Text('Código: ${classroom.code}'),
          pw.Text('Curso: ${classroom.courseName}'),
          pw.Text('Total de Estudiantes: ${classroom.studentsCount}'),
          if (classroom.description != null)
            pw.Text('Descripción: ${classroom.description}'),
        ],
      ),
    );
  }

  static pw.Widget _buildClassroomMetricsPDF(
    ClassroomModel classroom,
    Map<String, dynamic> metrics,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Métricas de Rendimiento',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Métrica', isHeader: true),
                _buildTableCell('Valor', isHeader: true),
                _buildTableCell('Estado', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Participación'),
                _buildTableCell('${metrics['participation']}%'),
                _buildTableCell(_getStatusText(metrics['participation'])),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Rendimiento'),
                _buildTableCell('${metrics['performance']}%'),
                _buildTableCell(_getStatusText(metrics['performance'])),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Tiempo Semanal'),
                _buildTableCell('${metrics['timeSpent']} horas'),
                _buildTableCell('Normal'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Progreso General'),
                _buildTableCell('${metrics['overall']}%'),
                _buildTableCell(_getStatusText(metrics['overall'])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStudentsListPDF(ClassroomModel classroom) {
    // Generar lista simulada de estudiantes
    final students = _generateSimulatedStudents(classroom);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Lista de Estudiantes (Simulada)',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Nombre', isHeader: true),
                _buildTableCell('Progreso %', isHeader: true),
                _buildTableCell('Última Actividad', isHeader: true),
                _buildTableCell('Estado', isHeader: true),
              ],
            ),
            ...students.map((student) => pw.TableRow(
              children: [
                _buildTableCell(student['name']!),
                _buildTableCell('${student['progress']}%'),
                _buildTableCell(student['lastActivity']!),
                _buildTableCell(student['status']!),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  // ============ MÉTODOS AUXILIARES PARA EXCEL ============

  static void _createGeneralSummarySheet(Excel excel, List<ClassroomModel> classrooms) {
    var sheet = excel['Resumen General'];
    
    // Header
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('COLEGIO LOS ÁNGELES - REPORTE GENERAL');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
    
    // Métricas generales
    final totalStudents = classrooms.fold<int>(0, (sum, classroom) => sum + classroom.studentsCount);
    final totalClassrooms = classrooms.length;
    final averageProgress = _calculateAverageProgress(classrooms);
    final activeStudents = _calculateActiveStudents(totalStudents);
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Total de Aulas:');
    sheet.cell(CellIndex.indexByString('B3')).value = IntCellValue(totalClassrooms);
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Total de Estudiantes:');
    sheet.cell(CellIndex.indexByString('B4')).value = IntCellValue(totalStudents);
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Progreso Promedio:');
    sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue('${averageProgress.round()}%');
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Estudiantes Activos Hoy:');
    sheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(activeStudents);
    
    // Fecha de generación
    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Generado el:');
    sheet.cell(CellIndex.indexByString('B8')).value = TextCellValue(DateTime.now().toString().split(' ')[0]);
  }

  static void _createClassroomsMetricsSheet(Excel excel, List<ClassroomModel> classrooms) {
    var sheet = excel['Métricas por Aula'];
    
    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Aula');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Código');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Curso');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Estudiantes');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Participación %');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Rendimiento %');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Tiempo (hrs)');
    sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Progreso General %');
    
    // Datos
    for (int i = 0; i < classrooms.length; i++) {
      final classroom = classrooms[i];
      final metrics = _generateClassroomMetrics(classroom);
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(classroom.name);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(classroom.code);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(classroom.courseName);
      sheet.cell(CellIndex.indexByString('D$row')).value = IntCellValue(classroom.studentsCount);
      sheet.cell(CellIndex.indexByString('E$row')).value = IntCellValue(metrics['participation']);
      sheet.cell(CellIndex.indexByString('F$row')).value = IntCellValue(metrics['performance']);
      sheet.cell(CellIndex.indexByString('G$row')).value = IntCellValue(metrics['timeSpent']);
      sheet.cell(CellIndex.indexByString('H$row')).value = IntCellValue(metrics['overall']);
    }
  }

  static void _createStudentsSheet(Excel excel, List<ClassroomModel> classrooms) {
    var sheet = excel['Estudiantes'];
    
    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Aula');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Estudiante');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Progreso %');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Última Actividad');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Estado');
    
    int currentRow = 2;
    for (final classroom in classrooms) {
      final students = _generateSimulatedStudents(classroom);
      
      for (final student in students) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(classroom.name);
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(student['name']!);
        sheet.cell(CellIndex.indexByString('C$currentRow')).value = TextCellValue('${student['progress']}%');
        sheet.cell(CellIndex.indexByString('D$currentRow')).value = TextCellValue(student['lastActivity']!);
        sheet.cell(CellIndex.indexByString('E$currentRow')).value = TextCellValue(student['status']!);
        currentRow++;
      }
    }
  }

  static void _createClassroomInfoSheet(Excel excel, ClassroomModel classroom) {
    var sheet = excel['Información del Aula'];
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('INFORMACIÓN DEL AULA');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Nombre:');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(classroom.name);
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Código:');
    sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue(classroom.code);
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Curso:');
    sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue(classroom.courseName);
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Total Estudiantes:');
    sheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(classroom.studentsCount);
    
    if (classroom.description != null) {
      sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Descripción:');
      sheet.cell(CellIndex.indexByString('B7')).value = TextCellValue(classroom.description!);
    }
  }

  static void _createClassroomMetricsSheet(Excel excel, ClassroomModel classroom) {
    var sheet = excel['Métricas'];
    final metrics = _generateClassroomMetrics(classroom);
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('MÉTRICAS DE RENDIMIENTO');
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Métrica');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue('Valor');
    sheet.cell(CellIndex.indexByString('C3')).value = TextCellValue('Estado');
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Participación');
    sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue('${metrics['participation']}%');
    sheet.cell(CellIndex.indexByString('C4')).value = TextCellValue(_getStatusText(metrics['participation']));
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Rendimiento');
    sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue('${metrics['performance']}%');
    sheet.cell(CellIndex.indexByString('C5')).value = TextCellValue(_getStatusText(metrics['performance']));
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Tiempo Semanal');
    sheet.cell(CellIndex.indexByString('B6')).value = TextCellValue('${metrics['timeSpent']} horas');
    sheet.cell(CellIndex.indexByString('C6')).value = TextCellValue('Normal');
    
    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Progreso General');
    sheet.cell(CellIndex.indexByString('B7')).value = TextCellValue('${metrics['overall']}%');
    sheet.cell(CellIndex.indexByString('C7')).value = TextCellValue(_getStatusText(metrics['overall']));
  }

  static void _createClassroomStudentsSheet(Excel excel, ClassroomModel classroom) {
    var sheet = excel['Estudiantes'];
    final students = _generateSimulatedStudents(classroom);
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nombre');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Progreso %');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Última Actividad');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Estado');
    
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(student['name']!);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue('${student['progress']}%');
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(student['lastActivity']!);
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(student['status']!);
    }
  }

  // ============ MÉTODOS AUXILIARES GENERALES ============

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
      subject: 'Reporte Académico',
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
        subject: 'Reporte Académico Excel',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel generado y compartido exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  static Map<String, dynamic> _generateClassroomMetrics(ClassroomModel classroom) {
    // Generar métricas basadas en el ID del aula para consistencia
    final seed = classroom.id;
    final participation = 60 + (seed % 35); // 60-95%
    final performance = 55 + (seed % 40); // 55-95%
    final timeSpent = 2 + (seed % 8); // 2-10 horas
    final overall = ((participation + performance) / 2).round();
    
    return {
      'participation': participation,
      'performance': performance,
      'timeSpent': timeSpent,
      'overall': overall,
    };
  }

  static double _calculateAverageProgress(List<ClassroomModel> classrooms) {
    if (classrooms.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final classroom in classrooms) {
      final metrics = _generateClassroomMetrics(classroom);
      totalProgress += metrics['overall'];
    }
    
    return totalProgress / classrooms.length;
  }

  static int _calculateActiveStudents(int totalStudents) {
    // Simular estudiantes activos (70-90% del total)
    return (totalStudents * (0.7 + (DateTime.now().day % 20) / 100)).round();
  }

  static String _getStatusText(int percentage) {
    if (percentage >= 80) return 'Excelente';
    if (percentage >= 60) return 'Bueno';
    if (percentage >= 40) return 'Regular';
    return 'Necesita Mejorar';
  }

  static List<Map<String, String>> _generateSimulatedStudents(ClassroomModel classroom) {
    final names = [
      'Ana García', 'Carlos López', 'María Rodríguez', 'Diego Martínez', 
      'Sofia Hernández', 'Pablo Jiménez', 'Valentina Castro', 'Mateo Silva',
      'Isabella Torres', 'Samuel Vargas', 'Camila Morales', 'Nicolás Ruiz',
      'Lucía Ortega', 'Sebastián Peña', 'Emma Delgado', 'Tomás Aguilar'
    ];
    
    final activities = [
      'Hace 1 hora', 'Hace 3 horas', 'Ayer', 'Hace 2 días', 
      'Hace 3 días', 'Esta semana', 'Hace 5 días'
    ];
    
    final statuses = ['Activo', 'Activo', 'Activo', 'Inactivo', 'Activo'];
    
    List<Map<String, String>> students = [];
    final studentCount = classroom.studentsCount > 0 ? classroom.studentsCount : 5;
    
    for (int i = 0; i < studentCount && i < names.length; i++) {
      final seed = classroom.id + i;
      final progress = 30 + (seed % 65); // 30-95%
      
      students.add({
        'name': names[i],
        'progress': progress.toString(),
        'lastActivity': activities[i % activities.length],
        'status': statuses[i % statuses.length],
      });
    }
    
    return students;
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
}