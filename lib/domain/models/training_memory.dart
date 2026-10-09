class TrainingMemory {
  final String id;
  final String category;
  final String learnedFact;
  final String promptTrigger;
  final String targetResponse;
  final double confidence;
  final DateTime createdAt;
  bool isActive;

  TrainingMemory({
    required this.id,
    required this.category,
    required this.learnedFact,
    required this.promptTrigger,
    required this.targetResponse,
    this.confidence = 1.0,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'learnedFact': learnedFact,
      'promptTrigger': promptTrigger,
      'targetResponse': targetResponse,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory TrainingMemory.fromMap(Map<String, dynamic> map) {
    return TrainingMemory(
      id: map['id'] as String,
      category: map['category'] as String,
      learnedFact: map['learnedFact'] as String,
      promptTrigger: (map['promptTrigger'] ?? '') as String,
      targetResponse: (map['targetResponse'] ?? '') as String,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] == 1 || map['isActive'] == true),
    );
  }
}
