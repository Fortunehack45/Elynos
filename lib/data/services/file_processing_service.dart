import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ExtractedFileItem {
  final String path;
  final String name;
  final int sizeBytes;
  final bool isDirectory;
  final String? textContent;

  ExtractedFileItem({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.isDirectory,
    this.textContent,
  });
}

class UnzipResult {
  final bool success;
  final String message;
  final String outputDirectory;
  final List<ExtractedFileItem> files;
  final int totalFiles;

  UnzipResult({
    required this.success,
    required this.message,
    required this.outputDirectory,
    required this.files,
    required this.totalFiles,
  });
}

class FileProcessingService {
  static final FileProcessingService _instance = FileProcessingService._internal();
  factory FileProcessingService() => _instance;
  FileProcessingService._internal();

  /// Unzips a zip file directly on the mobile device into the app workspace
  Future<UnzipResult> extractZipArchive(Uint8List zipBytes, String archiveName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetFolderName = 'workspace_${DateTime.now().millisecondsSinceEpoch}';
      final targetDir = Directory(p.join(appDir.path, targetFolderName));
      await targetDir.create(recursive: true);

      // Decode the zip archive
      final archive = ZipDecoder().decodeBytes(zipBytes);
      final extractedItems = <ExtractedFileItem>[];

      for (final file in archive) {
        final filename = file.name;
        final filePath = p.join(targetDir.path, filename);

        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          final data = file.content as List<int>;
          await outFile.writeAsBytes(data);

          String? text;
          // If text or code file, read snippet for context
          if (filename.endsWith('.dart') ||
              filename.endsWith('.txt') ||
              filename.endsWith('.md') ||
              filename.endsWith('.json') ||
              filename.endsWith('.html') ||
              filename.endsWith('.css') ||
              filename.endsWith('.js') ||
              filename.endsWith('.py')) {
            try {
              text = await outFile.readAsString();
              if (text.length > 5000) {
                text = '${text.substring(0, 5000)}\n... [truncated for context]';
              }
            } catch (_) {}
          }

          extractedItems.add(ExtractedFileItem(
            path: filePath,
            name: p.basename(filePath),
            sizeBytes: data.length,
            isDirectory: false,
            textContent: text,
          ));
        } else {
          await Directory(filePath).create(recursive: true);
          extractedItems.add(ExtractedFileItem(
            path: filePath,
            name: p.basename(filePath),
            sizeBytes: 0,
            isDirectory: true,
          ));
        }
      }

      return UnzipResult(
        success: true,
        message: 'Successfully unzipped ${extractedItems.where((e) => !e.isDirectory).length} files into workspace.',
        outputDirectory: targetDir.path,
        files: extractedItems,
        totalFiles: extractedItems.where((e) => !e.isDirectory).length,
      );
    } catch (e) {
      return UnzipResult(
        success: false,
        message: 'Error extracting zip archive: $e',
        outputDirectory: '',
        files: [],
        totalFiles: 0,
      );
    }
  }

  /// Reads attached document or image metadata
  Future<String> processAttachedFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 'File not found at $filePath';

    final name = p.basename(filePath);
    final sizeKb = (await file.length()) / 1024.0;
    final ext = p.extension(filePath).toLowerCase();

    if (ext == '.txt' || ext == '.md' || ext == '.dart' || ext == '.json' || ext == '.py') {
      final content = await file.readAsString();
      return 'File: $name (${sizeKb.toStringAsFixed(1)} KB)\nContent:\n$content';
    } else if (ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp') {
      return 'Image Attachment: $name (${sizeKb.toStringAsFixed(1)} KB) loaded into visual processing buffer.';
    } else {
      return 'Binary Attachment: $name (${sizeKb.toStringAsFixed(1)} KB).';
    }
  }
}
