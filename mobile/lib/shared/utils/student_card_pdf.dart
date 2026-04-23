import 'package:barcode/barcode.dart';
import 'package:mobile/core/models/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StudentCardPdf {
  static double _pt(double mm) => mm * 2.8346;

  static Future<void> print(Student student, String schoolName) async {
    final pdf = pw.Document();
    final qrSvg = Barcode.qrCode().toSvg(student.code, width: _pt(19), height: _pt(19));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(_pt(80), _pt(50), marginAll: 0),
        build: (_) => pw.Row(
          children: [
            pw.Container(
              width: _pt(30),
              color: PdfColor.fromHex('#f8f8f8'),
              child: pw.Center(
                child: pw.Container(
                  width: _pt(24),
                  height: _pt(30),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#dddddd'),
                    borderRadius: pw.BorderRadius.circular(2.835),
                  ),
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: _pt(2), vertical: _pt(2.5)),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      schoolName.toUpperCase(),
                      style: pw.TextStyle(fontSize: 5, color: PdfColor.fromHex('#aaaaaa')),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: _pt(0.8)),
                    pw.Text(
                      student.code,
                      style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#888888'), font: pw.Font.courier()),
                    ),
                    pw.SizedBox(height: _pt(0.8)),
                    pw.Text(
                      student.name,
                      style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                      maxLines: 2,
                    ),
                    pw.SizedBox(height: _pt(1.5)),
                    pw.SvgImage(svg: qrSvg, width: _pt(19), height: _pt(19)),
                    pw.SizedBox(height: _pt(0.8)),
                    pw.Text(
                      student.code,
                      style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex('#555555'), font: pw.Font.courier()),
                    ),
                    if (student.card != null)
                      pw.Padding(
                        padding: pw.EdgeInsets.only(top: _pt(0.8)),
                        child: pw.Text(
                          'v${student.card!.version} · ${_formatDate(student.card!.issuedAt)}',
                          style: pw.TextStyle(fontSize: 5, color: PdfColor.fromHex('#cccccc')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
