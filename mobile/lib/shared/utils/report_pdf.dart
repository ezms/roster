import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile/core/models/attendance_report.dart';

class ReportPdf {
  static Future<void> print(
    AttendanceReport report,
    String schoolName,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();
    const names = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final monthLabel = '${names[month - 1]}/$year';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header(schoolName, monthLabel),
          pw.SizedBox(height: 12),
          _summaryTable(report.summary),
          pw.SizedBox(height: 16),
          _sectionTitle('Registros de Chamadas'),
          pw.SizedBox(height: 6),
          _sessionsTable(report.sessions),
          if (report.topAbsentStudents.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Alunos com Mais Faltas'),
            pw.SizedBox(height: 6),
            _absentTable(report.topAbsentStudents),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static pw.Widget _header(String schoolName, String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          schoolName,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Relatório de Frequência — $period',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 0.5),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _summaryTable(ReportSummary s) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: ['Aulas', 'Presenças', 'Faltas', '% Presença']
              .map((h) => _cell(h, bold: true))
              .toList(),
        ),
        pw.TableRow(children: [
          _cell(s.totalSessions.toString()),
          _cell(s.totalPresences.toString()),
          _cell(s.totalAbsences.toString()),
          _cell('${s.attendanceRate.toStringAsFixed(0)}%'),
        ]),
      ],
    );
  }

  static pw.Widget _sessionsTable(List<ReportSession> sessions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: ['Data', 'Turma', 'Professor', 'Presenças', 'Faltas']
              .map((h) => _cell(h, bold: true))
              .toList(),
        ),
        ...sessions.map((s) {
          final d = s.openedAt.toLocal();
          final date =
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
          return pw.TableRow(children: [
            _cell(date),
            _cell(s.className),
            _cell(s.teacherName),
            _cell(s.presentCount.toString()),
            _cell(s.absentCount.toString()),
          ]);
        }),
      ],
    );
  }

  static pw.Widget _absentTable(List<ReportStudentAbsence> students) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: ['Aluno', 'Faltas'].map((h) => _cell(h, bold: true)).toList(),
        ),
        ...students.map((s) => pw.TableRow(children: [
              _cell(s.studentName),
              _cell(s.absenceCount.toString()),
            ])),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
