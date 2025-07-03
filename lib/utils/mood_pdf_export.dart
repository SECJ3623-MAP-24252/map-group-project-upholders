// lib/utils/mood_pdf_export.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MoodPdfExport {
  /// Generates a PDF document matching the chart summary (use scores from chart!)
  static Future<pw.Document> generateMoodChartReport(
    List<double> scores, {
    List<String>? labels,
    String title = "Mood Chart Report",
    String periodLabel = "",
  }) async {
    final pdf = pw.Document();

    final avg =
        scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
    final high = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
    final low = scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                periodLabel,
                style: pw.TextStyle(color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 8),
              pw.Text("Generated on: ${_formatDate(DateTime.now())}"),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                "Summary",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _summaryItem("Average", avg.toStringAsFixed(2)),
                    _summaryItem("Highest", high.toStringAsFixed(2)),
                    _summaryItem("Lowest", low.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Text(
                "Chart Data",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: labels != null ? ['Period', 'Score'] : ['#', 'Score'],
                data: List.generate(
                  scores.length,
                  (i) => [
                    labels != null ? labels[i] : (i + 1).toString(),
                    scores[i].toStringAsFixed(2),
                  ],
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.brown300,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                cellStyle: pw.TextStyle(fontSize: 11),
                cellAlignment: pw.Alignment.centerLeft,
                cellHeight: 22,
                border: null,
                oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 15,
            color: PdfColors.brown800,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(color: PdfColors.brown, fontSize: 11),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Save and share the PDF
  static Future<void> saveAndSharePdf(
    pw.Document pdf, {
    String fileName = "mood_chart_report.pdf",
  }) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: "Your Mood Chart Report");
  }
}
