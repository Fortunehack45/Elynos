import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/chat_message.dart';
import '../../../core/theme/elynos_theme.dart';
import '../../../../data/services/image_generation_service.dart';
import 'latex_markdown_renderer.dart';
import 'thinking_disclosure.dart';
import 'goal_milestones_card.dart';
import 'code_artifact_card.dart';
import 'visual_audit_card.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRegenerate,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAssistantMessage(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8, left: 48, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attached files indicator if any
            if (widget.message.attachedFiles != null && widget.message.attachedFiles!.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.message.attachedFiles!.map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
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
                        color: Colors.black,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        f.split('/').last.split('\\').last,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 6),
            ],
            SelectableText(
              widget.message.text,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 1.35,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thinking Disclosure Pill (Only when genuine thinking is present!)
          if (widget.message.hasThinking)
            ThinkingDisclosureWidget(
              thinkingProcess: widget.message.thinkingProcess!,
              durationSeconds: _calculateThinkingDuration(widget.message),
            ),

          // Main Markdown Response Text
          LatexMarkdownRenderer(content: widget.message.text),

          // Generated Image if present (with Zero Watermark clipper)
          if (widget.message.hasImage) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openImageFullscreen(context, widget.message.imageUrl!),
              child: Stack(
                children: [
                  WatermarkFreeImageWidget(
                    imageUrl: widget.message.imageUrl!,
                    height: 280,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Pre-Flight Visual QA Audit Card if present
          if (widget.message.hasVisualAudit) ...[
            const SizedBox(height: 8),
            VisualAuditCard(audit: widget.message.visualAudit!),
          ],

          // Goal Interactive Milestones if present
          if (widget.message.hasGoal) ...[
            const SizedBox(height: 8),
            GoalMilestonesCard(milestones: widget.message.goalMilestones!),
          ],

          // Code Artifact & GitHub Push if present
          if (widget.message.hasCodeArtifact) ...[
            const SizedBox(height: 8),
            CodeArtifactCard(code: widget.message.codeArtifact!),
          ],

          const SizedBox(height: 8),

          // Grok Action Row (1:1 with Screenshot: Copy, Share, Thumb Up, Thumb Down, Speaker, Refresh)
          Row(
            children: [
              _buildActionIcon(
                icon: Icons.copy_rounded,
                tooltip: 'Copy',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: widget.message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied response to clipboard'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              const SizedBox(width: 14),
              _buildActionIcon(
                icon: Icons.share_outlined,
                tooltip: 'Share',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: widget.message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Response link ready to share'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              const SizedBox(width: 14),
              _buildActionIcon(
                icon: _isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_outlined,
                tooltip: 'Good response',
                color: _isLiked ? Colors.black : const Color(0xFF757575),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isLiked = !_isLiked;
                    if (_isLiked) _isDisliked = false;
                  });
                },
              ),
              const SizedBox(width: 14),
              _buildActionIcon(
                icon: _isDisliked ? Icons.thumb_down_alt_rounded : Icons.thumb_down_outlined,
                tooltip: 'Bad response',
                color: _isDisliked ? Colors.black : const Color(0xFF757575),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isDisliked = !_isDisliked;
                    if (_isDisliked) _isLiked = false;
                  });
                },
              ),
              const SizedBox(width: 14),
              _buildActionIcon(
                icon: Icons.volume_up_outlined,
                tooltip: 'Read aloud',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing audio synthesis...'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              const SizedBox(width: 14),
              _buildActionIcon(
                icon: Icons.refresh_rounded,
                tooltip: 'Regenerate',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (widget.onRegenerate != null) {
                    widget.onRegenerate!();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = const Color(0xFF757575),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }

  void _openImageFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            WatermarkFreeImageWidget(
              imageUrl: url,
              borderRadius: BorderRadius.circular(16),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateThinkingDuration(ChatMessage message) {
    final len = message.thinkingProcess?.length ?? 120;
    if (message.mode == IntelligenceMode.expert) {
      return (len / 75).clamp(4, 16).toInt();
    } else if (message.mode == IntelligenceMode.heavy) {
      return (len / 60).clamp(5, 22).toInt();
    } else {
      return (len / 100).clamp(2, 9).toInt();
    }
  }
}
