import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeEmptyState extends StatelessWidget {
  final Function(String) onSelectPrompt;

  const HomeEmptyState({super.key, required this.onSelectPrompt});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Grok Minimalist Header
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'What do you want to\nexplore today?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.8,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elynos 1 Axiom • 100% Offline & Sovereign',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8E8E93),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 32),

            // Category Suggestions Grid
            _buildCategoryCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Think Deep on a complex problem',
              subtitle: 'Multi-hypothesis reasoning with strict RAM safety',
              onTap: () => onSelectPrompt('Explain how general relativity merges with quantum thermodynamics'),
            ),
            const SizedBox(height: 10),
            _buildCategoryCard(
              icon: Icons.image_outlined,
              title: 'Imagine & synthesize visuals',
              subtitle: 'Autonomous high-res image generation with zero watermark',
              onTap: () => onSelectPrompt('Generate an image of a cybernetic neon city at dusk'),
            ),
            const SizedBox(height: 10),
            _buildCategoryCard(
              icon: Icons.code_rounded,
              title: 'Build apps & inspect codebases',
              subtitle: 'Extract full ZIP archives, generate mobile-responsive code',
              onTap: () => onSelectPrompt('Build a complete Flutter state management architecture pattern'),
            ),
            const SizedBox(height: 10),
            _buildCategoryCard(
              icon: Icons.functions_rounded,
              title: 'Derive mathematical formulas',
              subtitle: 'LaTeX step-by-step proofs and equation solvers',
              onTap: () => onSelectPrompt('Derive the Euler-Lagrange equations of motion in classical mechanics'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFEAEAEB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
