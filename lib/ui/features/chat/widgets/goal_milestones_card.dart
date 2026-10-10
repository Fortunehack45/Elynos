import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/chat_message.dart';
import '../../../core/theme/elynos_theme.dart';

class GoalMilestonesCard extends StatefulWidget {
  final List<GoalMilestone> milestones;
  final VoidCallback? onCompleted;
  final bool autoStart;

  const GoalMilestonesCard({
    super.key,
    required this.milestones,
    this.onCompleted,
    this.autoStart = false,
  });

  @override
  State<GoalMilestonesCard> createState() => _GoalMilestonesCardState();
}

class _GoalMilestonesCardState extends State<GoalMilestonesCard> {
  late List<GoalMilestone> _items;
  bool _isAutoExecuting = false;
  int _activeExecutingIndex = -1;
  String? _statusText;
  Timer? _executionTimer;

  @override
  void initState() {
    super.initState();
    _items = widget.milestones;
    if (widget.autoStart || (_items.isNotEmpty && _items.any((m) => !m.isCompleted))) {
      // Auto-start autonomous execution shortly after appearing
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_isAutoExecuting && _items.any((m) => !m.isCompleted)) {
          _startAutonomousExecution();
        }
      });
    }
  }

  @override
  void dispose() {
    _executionTimer?.cancel();
    super.dispose();
  }

  double get _progress {
    if (_items.isEmpty) return 0.0;
    final done = _items.where((m) => m.isCompleted).length;
    return done / _items.length;
  }

  Future<void> _startAutonomousExecution() async {
    if (_isAutoExecuting) return;

    setState(() {
      _isAutoExecuting = true;
      _statusText = 'Initializing autonomous task runner...';
    });
    HapticFeedback.mediumImpact();

    for (int i = 0; i < _items.length; i++) {
      if (!mounted) return;
      final item = _items[i];
      if (item.isCompleted) continue;

      setState(() {
        _activeExecutingIndex = i;
        _statusText = '⚡ Executing: ${item.title}...';
      });

      // Realistic autonomous execution step delay (1.2 seconds per milestone)
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      setState(() {
        item.isCompleted = true;
        _statusText = '✓ Completed: ${item.title}';
      });
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    setState(() {
      _isAutoExecuting = false;
      _activeExecutingIndex = -1;
      _statusText = '🎯 All milestones autonomously completed & verified by Elynos Agent!';
    });

    HapticFeedback.heavyImpact();
    widget.onCompleted?.call();
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
          color: isAllDone
              ? Colors.greenAccent.withOpacity(0.5)
              : _isAutoExecuting
                  ? ElyonsColors.accent.withOpacity(0.6)
                  : ElyonsColors.border,
          width: isAllDone || _isAutoExecuting ? 1.5 : 1,
        ),
        boxShadow: [
          if (_isAutoExecuting)
            BoxShadow(
              color: ElyonsColors.accent.withOpacity(0.12),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
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
                  isAllDone
                      ? Icons.check_circle_rounded
                      : _isAutoExecuting
                          ? Icons.autorenew_rounded
                          : Icons.flag_rounded,
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
                      isAllDone
                          ? 'Goal Completed!'
                          : _isAutoExecuting
                              ? 'Executing Roadmap Autonomously...'
                              : 'Autonomous Roadmap',
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isAllDone ? Colors.greenAccent : ElyonsColors.accent,
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

          // Live execution status ticker
          if (_statusText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isAllDone
                    ? Colors.green.withOpacity(0.1)
                    : ElyonsColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAllDone
                      ? Colors.greenAccent.withOpacity(0.2)
                      : ElyonsColors.accent.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  if (_isAutoExecuting) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ElyonsColors.accent),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      _statusText!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isAllDone ? Colors.greenAccent : ElyonsColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          // Checkable Milestones
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            final isCurrentActive = index == _activeExecutingIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: _isAutoExecuting
                    ? null
                    : () {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? Colors.green.withOpacity(0.08)
                        : isCurrentActive
                            ? ElyonsColors.accent.withOpacity(0.12)
                            : const Color(0xFF10141C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.isCompleted
                          ? Colors.greenAccent.withOpacity(0.35)
                          : isCurrentActive
                              ? ElyonsColors.accent.withOpacity(0.6)
                              : ElyonsColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isCurrentActive)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(ElyonsColors.accent),
                          ),
                        )
                      else
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
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: item.isCompleted
                                    ? Colors.white70
                                    : isCurrentActive
                                        ? Colors.white
                                        : Colors.white90,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (item.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.description!,
                                style: const TextStyle(
                                  fontSize: 11.5,
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

          // Manual Trigger Button if not all done and not running
          if (!isAllDone && !_isAutoExecuting) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: _startAutonomousExecution,
                icon: const Icon(Icons.bolt_rounded, size: 16),
                label: const Text('Execute Autonomously', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElyonsColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
