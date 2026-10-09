import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/image_generation_service.dart';

class ImagineView extends StatefulWidget {
  const ImagineView({super.key});

  @override
  State<ImagineView> createState() => _ImagineViewState();
}

class _ImagineViewState extends State<ImagineView> {
  final _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedImageUrl;
  Uint8List? _generatedImageBytes;
  String? _errorMessage;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage([String? presetPrompt]) async {
    final prompt = presetPrompt ?? _promptController.text.trim();
    if (prompt.isEmpty) return;

    if (presetPrompt != null) {
      _promptController.text = presetPrompt;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final result = await ImageGenerationService().generateAndDownload(prompt);
      if (result.success && result.imageUrl != null) {
        setState(() {
          _generatedImageUrl = result.imageUrl;
          _generatedImageBytes = result.imageBytes;
          _isGenerating = false;
        });
      } else {
        // Fallback to direct network rendering with clean URL
        final directUrl = ImageGenerationService.buildImageUrl(prompt);
        setState(() {
          _generatedImageUrl = directUrl;
          _generatedImageBytes = null;
          _isGenerating = false;
        });
      }
    } catch (e) {
      // Direct network fallback
      final directUrl = ImageGenerationService.buildImageUrl(prompt);
      setState(() {
        _generatedImageUrl = directUrl;
        _generatedImageBytes = null;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grok Imagine Studio Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Imagine Studio',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Autonomous image synthesis • High resolution • Zero watermark',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),

                // Prompt Input Field
                TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Describe anything to imagine... e.g. "futuristic cybernetic skyline"',
                    hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14, fontWeight: FontWeight.w600),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Generate Button
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : () => _generateImage(),
                  icon: _isGenerating
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.brush_rounded, size: 16, color: Colors.white),
                  label: Text(
                    _isGenerating ? 'Synthesizing...' : 'Generate Image',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Preset Suggestions Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip('Neon Cyberpunk City'),
                const SizedBox(width: 8),
                _buildPromptChip('Futuristic Hypercar in Rain'),
                const SizedBox(width: 8),
                _buildPromptChip('Deep Space Nebula Galaxy'),
                const SizedBox(width: 8),
                _buildPromptChip('Cute Golden Retriever in Autumn'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Generated Image Display Area (Zero Watermark)
          Expanded(
            child: _isGenerating
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                          SizedBox(height: 14),
                          Text(
                            'Synthesizing high-res visual asset...',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Removing watermarks and certifying visual quality',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                : _generatedImageUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          WatermarkFreeImageWidget(
                            imageUrl: _generatedImageUrl!,
                            imageBytes: _generatedImageBytes,
                            borderRadius: BorderRadius.circular(20),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(ClipboardData(text: _generatedImageUrl!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Image link copied to clipboard'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Copy Link', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.palette_outlined, size: 52, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 12),
                              Text(
                                'Your generated visual creations appear here',
                                style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enter any prompt above to imagine with Elynos',
                                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label) {
    return InkWell(
      onTap: () => _generateImage(label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
    );
  }
}
