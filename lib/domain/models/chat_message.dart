import 'intelligence_mode.dart';

class GoalMilestone {
  final String id;
  final String title;
  final String? description;
  bool isCompleted;

  GoalMilestone({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory GoalMilestone.fromMap(Map<String, dynamic> map) {
    return GoalMilestone(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] == 1 || map['isCompleted'] == true),
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String sender; // 'user' or 'elynos'
  final String text;
  final String? thinkingProcess;
  final IntelligenceMode mode;
  final DateTime timestamp;
  final String? imageUrl;
  final String? codeArtifact;
  final List<GoalMilestone>? goalMilestones;
  final bool isTemporary;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.text,
    this.thinkingProcess,
    this.mode = IntelligenceMode.fast,
    required this.timestamp,
    this.imageUrl,
    this.codeArtifact,
    this.goalMilestones,
    this.isTemporary = false,
  });

  bool get isUser => sender == 'user';
  bool get hasThinking => thinkingProcess != null && thinkingProcess!.trim().isNotEmpty;
  bool get hasGoal => goalMilestones != null && goalMilestones!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get hasCodeArtifact => codeArtifact != null && codeArtifact!.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sender': sender,
      'text': text,
      'thinkingProcess': thinkingProcess,
      'mode': mode.name,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'codeArtifact': codeArtifact,
      'goalMilestones': goalMilestones != null
          ? goalMilestones!.map((m) => m.toMap()).toList()
          : null,
      'isTemporary': isTemporary ? 1 : 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    List<GoalMilestone>? milestones;
    if (map['goalMilestones'] != null) {
      final list = map['goalMilestones'] as List<dynamic>;
      milestones = list.map((item) => GoalMilestone.fromMap(Map<String, dynamic>.from(item))).toList();
    }

    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      thinkingProcess: map['thinkingProcess'] as String?,
      mode: IntelligenceMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => IntelligenceMode.fast,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      imageUrl: map['imageUrl'] as String?,
      codeArtifact: map['codeArtifact'] as String?,
      goalMilestones: milestones,
      isTemporary: (map['isTemporary'] == 1 || map['isTemporary'] == true),
    );
  }
}
