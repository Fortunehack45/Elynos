import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/elynos_theme.dart';

class ElyonsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onOpenDrawer;
  final bool isPrivateMode;
  final VoidCallback onTogglePrivate;

  const ElyonsAppBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.onOpenDrawer,
    required this.isPrivateMode,
    required this.onTogglePrivate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ElyonsColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Left: Hamburger Menu Button
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                onOpenDrawer();
              },
            ),

            const Spacer(),

            // Center: Segmented Navigation Tabs (Ask | Imagine | Build)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab('Ask', 0),
                const SizedBox(width: 14),
                _buildTab('Imagine', 1),
                const SizedBox(width: 14),
                _buildTab('Build', 2),
              ],
            ),

            const Spacer(),

            // Right: Private / Incognito Mode Mask Icon
            IconButton(
              icon: Icon(
                isPrivateMode ? Icons.visibility_off_rounded : Icons.visibility_off_outlined,
                color: isPrivateMode ? ElyonsColors.accent : ElyonsColors.textSecondary,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                onTogglePrivate();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = activeTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabChanged(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          // Active Indicator Pill Underline
          Container(
            height: 3,
            width: isSelected ? 22 : 0,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
