import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/intelligence_mode.dart';
import '../../../core/theme/elynos_theme.dart';

class ModeSelectorSheet extends StatelessWidget {
  final IntelligenceMode currentMode;
  final ValueChanged<IntelligenceMode> onModeSelected;

  const ModeSelectorSheet({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131720),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ElyonsColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              const Icon(Icons.blur_on_rounded, color: ElyonsColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Elynos Intelligence',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ElyonsColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '100% Free',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ElyonsColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Powered by Elynos 1 Axiom • 100k Virtual Context • Ultra Low RAM',
            style: TextStyle(fontSize: 13, color: ElyonsColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Modes List
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: IntelligenceMode.values.map((mode) {
                  final isSelected = mode == currentMode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onModeSelected(mode);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E2533) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? ElyonsColors.accent.withOpacity(0.4) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ElyonsColors.accent.withOpacity(0.2)
                                    : const Color(0xFF1A1F2B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                mode.icon,
                                color: isSelected ? ElyonsColors.accent : ElyonsColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        mode.displayName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.white70,
                                        ),
                                      ),
                                      if (mode.isBeta) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2C3242),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Beta',
                                            style: TextStyle(fontSize: 10, color: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    mode.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ElyonsColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: ElyonsColors.accent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
