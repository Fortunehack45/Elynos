class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  String lastMessageSnippet;
  bool isPinned;
  final bool isPrivate;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageSnippet = '',
    this.isPinned = false,
    this.isPrivate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessageSnippet': lastMessageSnippet,
      'isPinned': isPinned ? 1 : 0,
      'isPrivate': isPrivate ? 1 : 0,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      lastMessageSnippet: (map['lastMessageSnippet'] ?? '') as String,
      isPinned: (map['isPinned'] == 1 || map['isPinned'] == true),
      isPrivate: (map['isPrivate'] == 1 || map['isPrivate'] == true),
    );
  }
}
