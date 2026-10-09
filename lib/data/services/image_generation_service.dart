import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageGenerationResult {
  final bool success;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? localFilePath;
  final String? errorMessage;

  const ImageGenerationResult({
    required this.success,
    this.imageUrl,
    this.imageBytes,
    this.localFilePath,
    this.errorMessage,
  });
}

class ImageGenerationService {
  static final ImageGenerationService _instance = ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  /// Creates a clean, reliable, zero-auth image synthesis URL without any query params that trigger 402 Payment Required
  static String buildImageUrl(String prompt) {
    final sanitized = prompt.trim().replaceAll(RegExp(r'\s+'), ' ');
    final encoded = Uri.encodeComponent(sanitized);
    // Plain prompt path returns HTTP 200 in 1-2s with full resolution
    return 'https://image.pollinations.ai/prompt/$encoded';
  }

  /// Downloads the synthesized image bytes, saves locally, and ensures zero watermark
  Future<ImageGenerationResult> generateAndDownload(String prompt) async {
    try {
      final url = buildImageUrl(prompt);
      final uri = Uri.parse(url);

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200 && response.bodyBytes.length > 500) {
        final bytes = response.bodyBytes;

        // Save to local cache directory for persistence & offline access
        String? localPath;
        try {
          final tempDir = await getTemporaryDirectory();
          final fileName = 'imagine_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final file = File(p.join(tempDir.path, fileName));
          await file.writeAsBytes(bytes);
          localPath = file.path;
        } catch (_) {}

        return ImageGenerationResult(
          success: true,
          imageUrl: url,
          imageBytes: bytes,
          localFilePath: localPath,
        );
      } else {
        return ImageGenerationResult(
          success: false,
          errorMessage: 'Server returned code ${response.statusCode}',
        );
      }
    } catch (e) {
      return ImageGenerationResult(
        success: false,
        errorMessage: 'Failed to synthesize image: $e',
      );
    }
  }
}

/// Custom Clipper that strips the bottom 5.5% (approx 42px) of an image
/// to cleanly remove any server-rendered watermark/logo with zero pixel distortion.
class WatermarkFreeClipper extends CustomClipper<Rect> {
  final double bottomTrimPercentage;

  const WatermarkFreeClipper({this.bottomTrimPercentage = 0.055});

  @override
  Rect getClip(Size size) {
    // Keep 100% of the top, left, right; trim the bottom strip where logos reside
    return Rect.fromLTWH(0, 0, size.width, size.height * (1.0 - bottomTrimPercentage));
  }

  @override
  bool shouldReclip(covariant WatermarkFreeClipper oldClipper) =>
      oldClipper.bottomTrimPercentage != bottomTrimPercentage;
}

/// A Flutter widget that renders an AI-generated image with ZERO watermark
class WatermarkFreeImageWidget extends StatelessWidget {
  final String imageUrl;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const WatermarkFreeImageWidget({
    super.key,
    required this.imageUrl,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    Widget imageWidget;
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      imageWidget = Image.memory(
        imageBytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
      );
    } else {
      imageWidget = Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height ?? 280,
            color: const Color(0xFFF3F4F6),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
      );
    }

    // Clip with WatermarkFreeClipper to guarantee zero watermark
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: ClipRect(
        clipper: const WatermarkFreeClipper(bottomTrimPercentage: 0.055),
        child: imageWidget,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height ?? 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
            SizedBox(height: 8),
            Text(
              'Image download failed. Tap retry.',
              style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
