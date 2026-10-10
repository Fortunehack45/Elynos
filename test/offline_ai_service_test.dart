import 'package:flutter_test/flutter_test.dart';
import 'package:elynos_ai/domain/models/intelligence_mode.dart';
import 'package:elynos_ai/domain/models/chat_message.dart';
import 'package:elynos_ai/domain/models/training_memory.dart';
import 'package:elynos_ai/data/services/offline_ai_service.dart';

void main() {
  group('OfflineAiService Tests', () {
    late OfflineAiService service;

    setUp(() {
      service = OfflineAiService();
    });

    test('Fast mode generates instant local response', () async {
      final response = await service.generateResponse(
        prompt: 'Hello Elynos',
        mode: IntelligenceMode.fast,
        activeMemories: [],
      );

      expect(response.text.contains('Elynos AI'), isTrue);
      expect(response.thinkingProcess, isNull);
    });

    test('Expert mode generates thinking process and solution', () async {
      final response = await service.generateResponse(
        prompt: 'Optimize matrix multiplication',
        mode: IntelligenceMode.expert,
        activeMemories: [],
      );

      expect(response.thinkingProcess, isNotNull);
      expect(response.thinkingProcess!.contains('Hypothesis'), isTrue);
      expect(response.text.contains('Analysis'), isTrue);
    });

    test('Goal mode produces checkable milestones', () async {
      final response = await service.generateResponse(
        prompt: 'Build my next app',
        mode: IntelligenceMode.goal,
        activeMemories: [],
      );

      expect(response.goalMilestones, isNotNull);
      expect(response.goalMilestones!.length, greaterThan(1));
      expect(response.goalMilestones!.first.title.isNotEmpty, isTrue);
    });

    test('Study mode produces LaTeX formula derivations', () async {
      final response = await service.generateResponse(
        prompt: 'Teach me calculus',
        mode: IntelligenceMode.study,
        activeMemories: [],
      );

      expect(response.text.contains(r'$$'), isTrue);
    });

    test('On-device trained memories are incorporated into offline response', () async {
      final memory = TrainingMemory(
        id: 'mem_1',
        category: 'Personal Knowledge',
        learnedFact: 'User prefers functional programming with immutability',
        promptTrigger: 'my style',
        targetResponse: 'User prefers functional programming',
        createdAt: DateTime.now(),
        isActive: true,
      );

      final response = await service.generateResponse(
        prompt: 'Remember my style when writing code',
        mode: IntelligenceMode.fast,
        activeMemories: [memory],
      );

      expect(response.text.contains('Personal Knowledge Applied'), isTrue);
      expect(response.text.contains('functional programming'), isTrue);
    });

    test('OfflineAiService confirms Elynos 1 Axiom model architecture', () {
      expect(OfflineAiService.modelName, 'Elynos 1 Axiom');
      expect(OfflineAiService.maxVirtualContextTokens, 100000);
      expect(OfflineAiService.activeRamWindowTokens, 4096);
    });

    test('Visual perception inspects image and generates pre-flight QA report', () async {
      final response = await service.generateResponse(
        prompt: 'Look at this diagram and visualize it',
        mode: IntelligenceMode.fast,
        activeMemories: [],
        attachedFiles: ['mockup_screen.png'],
      );

      expect(response.visualAudit, isNotNull);
      expect(response.visualAudit!.preFlightApproved, isTrue);
      expect(response.visualAudit!.qualityScore, greaterThan(0.90));
      expect(response.text.contains('Visual') || response.text.contains('visual'), isTrue);
    });

    test('Algebraic equation solver resolves for variable X in x^2+y^2=X5', () async {
      final response = await service.generateResponse(
        prompt: 'What is the value of X if x^2+y^2=X5',
        mode: IntelligenceMode.fast,
        activeMemories: [],
      );

      expect(response.text.contains('X'), isTrue);
      expect(response.text.contains('x^2') || response.text.contains('x²'), isTrue);
      expect(response.text.contains('5'), isTrue);
      expect(response.text.contains(r'$$'), isTrue);
    });

    test('Multi-turn context handles follow-up inquiry asking for the answer', () async {
      final history = [
        ChatMessage(
          id: '1',
          conversationId: 'c1',
          sender: 'user',
          text: 'What is the value of X if x^2+y^2=X5',
          mode: IntelligenceMode.fast,
          timestamp: DateTime.now(),
        ),
      ];

      final response = await service.generateResponse(
        prompt: 'please the answer...',
        mode: IntelligenceMode.fast,
        activeMemories: [],
        conversationHistory: history,
      );

      expect(response.text.contains('X'), isTrue);
      expect(response.text.contains('5'), isTrue);
      expect(response.text.contains('x^2') || response.text.contains('x²'), isTrue);
    });

    test('LaTeX notation processor formats complexity and provides amortized breakdown', () async {
      final response = await service.generateResponse(
        prompt: r'\mathcal{O}(N \log N) \quad \text{complexity with amortized local cache}',
        mode: IntelligenceMode.fast,
        activeMemories: [],
      );

      expect(response.text.contains(r'$$'), isTrue);
      expect(response.text.contains('O(N') || response.text.contains('linearithmic') || response.text.contains('amortized'), isTrue);
    });
  });
}
