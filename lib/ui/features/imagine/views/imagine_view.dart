import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/elynos_theme.dart';

class ImagineView extends StatefulWidget {
  const ImagineView({super.key});

  @override
  State<ImagineView> createState() => _ImagineViewState();
}

class _ImagineViewState extends State<ImagineView> {
  final _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedImageUrl;

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });
    HapticFeedback.mediumImpact();

    // Generate image via free zero-auth endpoint or local preview
    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=800&height=800&nologo=true';

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _generatedImageUrl = url;
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131822),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ElyonsColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎨 Elynos Imagine Studio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Autonomous image synthesis with zero sign-up required',
                  style: TextStyle(fontSize: 13, color: ElyonsColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Describe anything to imagine... e.g. "futuristic cybernetic skyline"',
                    hintStyle: const TextStyle(color: ElyonsColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF181F2C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ElyonsColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateImage,
                  icon: _isGenerating
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: Text(_isGenerating ? 'Synthesizing...' : 'Generate Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElyonsColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _generatedImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _generatedImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('Connect to internet to download generated image.', style: TextStyle(color: Colors.orangeAccent)),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image_outlined, size: 54, color: ElyonsColors.textMuted),
                        SizedBox(height: 12),
                        Text('Your generated creations will appear here', style: TextStyle(color: ElyonsColors.textSecondary)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
