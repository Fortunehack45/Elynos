import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class GeneratedDocumentResult {
  final bool success;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final String format;

  GeneratedDocumentResult({
    required this.success,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.format,
  });
}

class DocumentGeneratorService {
  static final DocumentGeneratorService _instance = DocumentGeneratorService._internal();
  factory DocumentGeneratorService() => _instance;
  DocumentGeneratorService._internal();

  /// Generates a beautifully formatted PDF document with title, sections, and code blocks
  Future<GeneratedDocumentResult> generatePdfDocument({
    required String title,
    required String author,
    required List<String> sections,
    String? codeBlock,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.Text(
                      'Elynos 1 Axiom',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Generated: ${DateTime.now().toIso8601String().split('T')[0]} • Author: $author',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              ...sections.map((sec) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Text(sec, style: const pw.TextStyle(fontSize: 12, lineSpacing: 2)),
                  )),
              if (codeBlock != null) ...[
                pw.SizedBox(height: 8),
                pw.Text('Source Code Artifact:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    codeBlock,
                    style: pw.TextStyle(font: pw.Font.courier(), fontSize: 9),
                  ),
                ),
              ],
            ];
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'elynos_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(p.join(dir.path, fileName));
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      return GeneratedDocumentResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        fileSizeBytes: bytes.length,
        format: 'PDF',
      );
    } catch (e) {
      return GeneratedDocumentResult(
        success: false,
        filePath: '',
        fileName: '',
        fileSizeBytes: 0,
        format: 'PDF',
      );
    }
  }

  /// Generates a Markdown document (.md)
  Future<GeneratedDocumentResult> generateMarkdownDocument({
    required String title,
    required String markdownBody,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'elynos_${DateTime.now().millisecondsSinceEpoch}.md';
      final file = File(p.join(dir.path, fileName));

      final content = '# $title\n\n'
          '*Authored by Elynos 1 Axiom Sovereign Edge AI*\n\n'
          '---\n\n'
          '$markdownBody';

      await file.writeAsString(content);
      final bytes = await file.length();

      return GeneratedDocumentResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        fileSizeBytes: bytes,
        format: 'Markdown',
      );
    } catch (e) {
      return GeneratedDocumentResult(
        success: false,
        filePath: '',
        fileName: '',
        fileSizeBytes: 0,
        format: 'Markdown',
      );
    }
  }
}
