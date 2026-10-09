import 'package:flutter/material.dart';
import '../../../core/theme/elynos_theme.dart';

class PrivateChatEmptyState extends StatelessWidget {
  const PrivateChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Watermark Icon (Mask / Incognito)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161C26),
                shape: BoxShape.circle,
                border: Border.all(color: ElyonsColors.border, width: 1),
              ),
              child: const Icon(
                Icons.visibility_off_outlined,
                size: 54,
                color: ElyonsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Private Chat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              'This chat won\'t appear in your history and will not be used to train models.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ElyonsColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
