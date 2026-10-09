import 'package:flutter/material.dart';

enum IntelligenceMode {
  fast,
  expert,
  build,
  heavy,
  auto,
  research,
  study,
  goal,
}

extension IntelligenceModeExtension on IntelligenceMode {
  String get displayName {
    switch (this) {
      case IntelligenceMode.fast:
        return 'Fast';
      case IntelligenceMode.expert:
        return 'Expert';
      case IntelligenceMode.build:
        return 'Build';
      case IntelligenceMode.heavy:
        return 'Heavy';
      case IntelligenceMode.auto:
        return 'Auto';
      case IntelligenceMode.research:
        return 'Research';
      case IntelligenceMode.study:
        return 'Study';
      case IntelligenceMode.goal:
        return 'Goal';
    }
  }

  String get subtitle {
    switch (this) {
      case IntelligenceMode.fast:
        return 'Quick responses • 100% Offline';
      case IntelligenceMode.expert:
        return 'Thinks hard • Deep reasoning tree';
      case IntelligenceMode.build:
        return 'Build apps & sites • Push to GitHub';
      case IntelligenceMode.heavy:
        return 'Team of Experts • Multi-perspective';
      case IntelligenceMode.auto:
        return 'Chooses Fast or Expert automatically';
      case IntelligenceMode.research:
        return 'In-depth analysis & synthesis';
      case IntelligenceMode.study:
        return 'Student tutor • Formulas & LaTeX';
      case IntelligenceMode.goal:
        return 'Interactive milestone to-do tracker';
    }
  }

  IconData get icon {
    switch (this) {
      case IntelligenceMode.fast:
        return Icons.bolt_rounded;
      case IntelligenceMode.expert:
        return Icons.lightbulb_outline_rounded;
      case IntelligenceMode.build:
        return Icons.handyman_outlined;
      case IntelligenceMode.heavy:
        return Icons.groups_outlined;
      case IntelligenceMode.auto:
        return Icons.rocket_launch_outlined;
      case IntelligenceMode.research:
        return Icons.travel_explore_rounded;
      case IntelligenceMode.study:
        return Icons.school_outlined;
      case IntelligenceMode.goal:
        return Icons.flag_outlined;
    }
  }

  bool get isBeta => this == IntelligenceMode.build;

  bool get worksOffline => this != IntelligenceMode.build && this != IntelligenceMode.research;
}
