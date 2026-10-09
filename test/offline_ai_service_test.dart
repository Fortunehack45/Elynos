import 'package:flutter_test/flutter_test.dart';
import 'package:elynos_ai/domain/models/intelligence_mode.dart';
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
  });
}
