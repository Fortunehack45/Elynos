import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../home/view_models/home_view_model.dart';
import '../../chat/widgets/chat_bubble.dart';
import '../../../core/theme/elynos_theme.dart';

class ImagineView extends StatelessWidget {
  const ImagineView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    // Messages relevant to Imagine stream
    final imageMessages = viewModel.messages.where((m) {
      if (m.imageUrl != null) return true;
      final textLower = m.text.toLowerCase();
      return textLower.contains('image') ||
          textLower.contains('draw') ||
          textLower.contains('picture') ||
          textLower.contains('paint') ||
          textLower.contains('synthesize');
    }).toList();

    if (imageMessages.isEmpty) {
      return _buildImagineEmptyState(context, viewModel);
    }

    final totalCount = imageMessages.length + (viewModel.isLoading ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == imageMessages.length && viewModel.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: ElyonsColors.accent),
                const SizedBox(width: 8),
                const Text(
                  'Synthesizing high-res image (watermark-free)...',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: ElyonsColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ElyonsColors.accent),
                  ),
                ),
              ],
            ),
          );
        }

        final message = imageMessages[index];
        return ChatBubble(
          message: message,
          onRegenerate: () {
            viewModel.sendMessage(message.text);
          },
        );
      },
    );
  }

  Widget _buildImagineEmptyState(BuildContext context, HomeViewModel viewModel) {
    final suggestions = [
      '🌆 Cyberpunk neon metropolis in rain',
      '🏎️ Futuristic electric supercar on mountain pass',
      '🌌 Deep space nebula cosmic gateway',
      '🎨 Minimalist 3D isometric glass cube',
      '🐶 Golden retriever puppy on autumn leaves',
      '☕ Cozy retro coffee shop interior at night',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Sparkle Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, size: 30, color: Colors.black),
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Imagine Studio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Autonomous visual synthesis • High resolution • 100% watermark-free',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Prompt Suggestion Chips
            Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions.map((prompt) {
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.sendMessage(prompt);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Type any description below to generate',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
