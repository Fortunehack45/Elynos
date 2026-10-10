import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../home/view_models/home_view_model.dart';
import '../../chat/widgets/chat_bubble.dart';
import '../../../../domain/models/intelligence_mode.dart';
import '../../../core/theme/elynos_theme.dart';

class BuildModeView extends StatelessWidget {
  const BuildModeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    // Messages relevant to Build stream
    final buildMessages = viewModel.messages.where((m) {
      if (m.codeArtifact != null) return true;
      if (m.mode == IntelligenceMode.build) return true;
      final textLower = m.text.toLowerCase();
      return textLower.contains('build') ||
          textLower.contains('code') ||
          textLower.contains('component') ||
          textLower.contains('widget') ||
          textLower.contains('calculator') ||
          textLower.contains('portfolio') ||
          textLower.contains('app');
    }).toList();

    if (buildMessages.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    final totalCount = buildMessages.length + (viewModel.isLoading ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == buildMessages.length && viewModel.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.code_rounded, size: 16, color: ElyonsColors.accent),
                const SizedBox(width: 8),
                const Text(
                  'Constructing production code artifact...',
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

        final message = buildMessages[index];
        return ChatBubble(
          message: message,
          onRegenerate: () {
            viewModel.sendMessage(message.text);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeViewModel viewModel) {
    final templates = [
      '🧮 Interactive Calculator Widget',
      '🌐 Developer Portfolio Website',
      '📱 Responsive Task Manager Widget',
      '🐍 Python O(N) Data Pipeline',
      '🌦️ Realtime Weather Card Component',
      '🔐 Secure Auth Form with Validation',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Code Brackets Glowing Icon
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
                child: Icon(Icons.terminal_rounded, size: 30, color: Colors.black),
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Build Studio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Autonomous software engineer • Clean architecture • Production ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Starter Template Chips
            Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: templates.map((template) {
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.sendMessage('Build: $template');
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
                      template,
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
              'Describe any component or application below to build',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
