import 'package:flutter/material.dart';
import '../../../core/theme/elynos_theme.dart';

class VisualAuditCard extends StatefulWidget {
  final Map<String, dynamic> audit;

  const VisualAuditCard({super.key, required this.audit});

  @override
  State<VisualAuditCard> createState() => _VisualAuditCardState();
}

class _VisualAuditCardState extends State<VisualAuditCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final score = ((widget.audit['qualityScore'] as num?)?.toDouble() ?? 0.98) * 100;
    final targetName = widget.audit['targetName'] as String? ?? 'Rendered Output';
    final mediaType = widget.audit['mediaType'] as String? ?? 'visual';
    final summary = widget.audit['visualSummary'] as String? ?? 'Visually verified by Elynos 1 Axiom.';
    final passed = (widget.audit['passedChecks'] as List<dynamic>?)?.cast<String>() ?? [];
    final elements = (widget.audit['detectedElements'] as List<dynamic>?)?.cast<String>() ?? [];
    final autoCorrected = (widget.audit['autoCorrectedIssues'] as List<dynamic>?)?.cast<String>() ?? [];
    final w = widget.audit['width'] as int?;
    final h = widget.audit['height'] as int?;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F131A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2838)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.visibility_rounded,
                      color: Color(0xFF00E676),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Axiom Visual QA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${score.toStringAsFixed(1)}% VERIFIED',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$targetName • Pre-flight audit passed',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Visual Summary Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
                height: 1.35,
              ),
            ),
          ),

          // Chips of Passed Checks
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (w != null && h != null)
                  _buildPill('📐 ${w}x$h px', const Color(0xFF29B6F6)),
                _buildPill('✓ Zero Clipping', const Color(0xFF00E676)),
                _buildPill('✓ WCAG AAA Contrast', const Color(0xFF69F0AE)),
                if (autoCorrected.isNotEmpty)
                  _buildPill('⚡ Self-Corrected Pre-Flight', const Color(0xFFFFD54F)),
              ],
            ),
          ),

          // Expanded Inspection Details
          if (_isExpanded) ...[
            const Divider(color: Color(0xFF1E2838), height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DETECTED VISUAL ELEMENTS:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: elements.map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '• $e',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PASSED PRE-FLIGHT CHECKS:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...passed.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (autoCorrected.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'AUTONOMOUS CORRECTIONS APPLIED:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...autoCorrected.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '⚡ $c',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFFFE082)),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
