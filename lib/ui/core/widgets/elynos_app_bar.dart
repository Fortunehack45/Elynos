import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/elynos_theme.dart';

class ElyonsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onOpenDrawer;
  final VoidCallback onNewChat;
  final bool isPrivateMode;
  final VoidCallback onTogglePrivate;

  const ElyonsAppBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.onOpenDrawer,
    required this.onNewChat,
    required this.isPrivateMode,
    required this.onTogglePrivate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Left: Grok-style Hamburger Menu Button (= two parallel lines)
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onOpenDrawer();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 2.2,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 16,
                        height: 2.2,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Center: Grok Segmented Navigation Tabs (Ask | Imagine | Build)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab('Ask', 0),
                const SizedBox(width: 18),
                _buildTab('Imagine', 1),
                const SizedBox(width: 18),
                _buildTab('Build', 2),
              ],
            ),

            const Spacer(),

            // Right: Grok-style New Chat Edit Note Button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onNewChat();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = activeTab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.black : const Color(0xFF8E8E93),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          // Grok Active Underline Indicator Bar
          Container(
            height: 3,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
