import 'package:flutter/material.dart';
import '../../../../domain/models/chat_message.dart';
import '../../../core/theme/elynos_theme.dart';
import 'latex_markdown_renderer.dart';
import 'thinking_disclosure.dart';
import 'goal_milestones_card.dart';
import 'code_artifact_card.dart';
import 'visual_audit_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAssistantBubble(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: const Color(0xFF232936),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
          border: Border.all(color: ElyonsColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attached files indicator if any
            if (message.attachedFiles != null && message.attachedFiles!.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: message.attachedFiles!.map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13171F),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ElyonsColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.toLowerCase().endsWith('.zip')
                            ? Icons.folder_zip_rounded
                            : (f.toLowerCase().endsWith('.png') || f.toLowerCase().endsWith('.jpg'))
                                ? Icons.image_rounded
                                : Icons.description_rounded,
                        color: ElyonsColors.accent,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        f.split('/').last.split('\\').last,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
            ],
            SelectableText(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.92),
        decoration: BoxDecoration(
          color: const Color(0xFF13171F),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: ElyonsColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elynos Header Label with Mode
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: ElyonsColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.black, size: 12),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Elynos',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E242E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    message.mode.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ElyonsColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Expandable Thinking Disclosure if present
            if (message.hasThinking)
              ThinkingDisclosureWidget(thinkingProcess: message.thinkingProcess!),

            // Markdown & LaTeX Rendered Body
            LatexMarkdownRenderer(content: message.text),

            // Pre-Flight Visual QA Audit Card if present
            if (message.hasVisualAudit)
              VisualAuditCard(audit: message.visualAudit!),

            // Goal Interactive Milestones if present
            if (message.hasGoal)
              GoalMilestonesCard(milestones: message.goalMilestones!),

            // Code Artifact & GitHub Push if present
            if (message.hasCodeArtifact)
              CodeArtifactCard(code: message.codeArtifact!),
          ],
        ),
      ),
    );
  }
}
