import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/elynos_theme.dart';

class HomeEmptyState extends StatelessWidget {
  final Function(String) onSelectPrompt;

  const HomeEmptyState({super.key, required this.onSelectPrompt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Center Watermark & Logo
        Expanded(
          child: Center(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    size: 58,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Quick Suggestion Pills (Screenshot 4)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildPill(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Think Deep on a Problem',
                onTap: () => onSelectPrompt('Explain quantum superposition with step-by-step reasoning'),
              ),
              const SizedBox(width: 8),
              _buildPill(
                icon: Icons.handyman_outlined,
                label: 'Build apps and sites',
                onTap: () => onSelectPrompt('Build a mobile-responsive modern calculator web app'),
              ),
              const SizedBox(width: 8),
              _buildPill(
                icon: Icons.school_outlined,
                label: 'Derive LaTeX formula',
                onTap: () => onSelectPrompt('Derive the Euler-Lagrange equation with LaTeX formulas'),
              ),
              const SizedBox(width: 8),
              _buildPill(
                icon: Icons.flag_outlined,
                label: 'Plan a 7-day Goal',
                onTap: () => onSelectPrompt('Create a 7-day milestone roadmap to build an offline AI app'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF161C26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ElyonsColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: ElyonsColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
