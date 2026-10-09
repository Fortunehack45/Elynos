import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThinkingDisclosureWidget extends StatefulWidget {
  final String thinkingProcess;
  final int durationSeconds;

  const ThinkingDisclosureWidget({
    super.key,
    required this.thinkingProcess,
    this.durationSeconds = 1,
  });

  @override
  State<ThinkingDisclosureWidget> createState() => _ThinkingDisclosureWidgetState();
}

class _ThinkingDisclosureWidgetState extends State<ThinkingDisclosureWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grok Thinking Pill: 💡 Thought for 1s >
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Thought for ${widget.durationSeconds}s',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF757575),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Reasoning Tree Content
          if (_isExpanded)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: SelectableText(
                widget.thinkingProcess,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Color(0xFF374151),
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
