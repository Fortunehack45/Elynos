import 'package:flutter/material.dart';
import '../../../core/theme/elynos_theme.dart';

class ThinkingDisclosureWidget extends StatefulWidget {
  final String thinkingProcess;

  const ThinkingDisclosureWidget({super.key, required this.thinkingProcess});

  @override
  State<ThinkingDisclosureWidget> createState() => _ThinkingDisclosureWidgetState();
}

class _ThinkingDisclosureWidgetState extends State<ThinkingDisclosureWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131820),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpanded ? ElyonsColors.accent.withOpacity(0.4) : ElyonsColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar (Clickable)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ElyonsColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: ElyonsColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Thought Process',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ElyonsColors.accent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isExpanded ? 'Hide' : 'Expand',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ElyonsColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: ElyonsColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Reasoning Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F131A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ElyonsColors.border.withOpacity(0.6)),
                ),
                child: SelectableText(
                  widget.thinkingProcess,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
                    color: ElyonsColors.textSecondary,
                  ),
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
