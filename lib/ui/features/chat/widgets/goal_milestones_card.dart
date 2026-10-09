import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/chat_message.dart';
import '../../../core/theme/elynos_theme.dart';

class GoalMilestonesCard extends StatefulWidget {
  final List<GoalMilestone> milestones;
  final VoidCallback? onCompleted;

  const GoalMilestonesCard({
    super.key,
    required this.milestones,
    this.onCompleted,
  });

  @override
  State<GoalMilestonesCard> createState() => _GoalMilestonesCardState();
}

class _GoalMilestonesCardState extends State<GoalMilestonesCard> {
  late List<GoalMilestone> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.milestones;
  }

  double get _progress {
    if (_items.isEmpty) return 0.0;
    final done = _items.where((m) => m.isCompleted).length;
    return done / _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final isAllDone = progress == 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAllDone ? Colors.greenAccent.withOpacity(0.5) : ElyonsColors.border,
          width: isAllDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Goal Progress Ring
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isAllDone ? Colors.greenAccent : ElyonsColors.accent).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAllDone ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: isAllDone ? Colors.greenAccent : ElyonsColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAllDone ? 'Goal Completed!' : 'Active Roadmap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAllDone ? Colors.greenAccent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(_items.where((m) => m.isCompleted).length)} of ${_items.length} milestones finished',
                      style: const TextStyle(fontSize: 12, color: ElyonsColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ElyonsColors.accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF262C36),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllDone ? Colors.greenAccent : ElyonsColors.accent,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Checkable Milestones
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    item.isCompleted = !item.isCompleted;
                  });
                  if (item.isCompleted && _progress == 1.0) {
                    HapticFeedback.heavyImpact();
                    widget.onCompleted?.call();
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? Colors.green.withOpacity(0.08)
                        : const Color(0xFF10141C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.isCompleted
                          ? Colors.greenAccent.withOpacity(0.3)
                          : ElyonsColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        color: item.isCompleted ? Colors.greenAccent : ElyonsColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: item.isCompleted ? Colors.white70 : Colors.white,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (item.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ElyonsColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
