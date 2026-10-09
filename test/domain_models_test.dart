import 'package:flutter_test/flutter_test.dart';
import 'package:elynos_ai/domain/models/intelligence_mode.dart';
import 'package:elynos_ai/domain/models/chat_message.dart';
import 'package:elynos_ai/domain/models/conversation.dart';
import 'package:elynos_ai/domain/models/training_memory.dart';
import 'package:elynos_ai/domain/models/build_project.dart';

void main() {
  group('Domain Models Serialization Tests', () {
    test('ChatMessage correctly serializes and deserializes', () {
      final msg = ChatMessage(
        id: 'msg_1',
        conversationId: 'conv_1',
        sender: 'user',
        text: 'Test message',
        mode: IntelligenceMode.expert,
        timestamp: DateTime(2026, 10, 9, 12, 0),
        thinkingProcess: 'Step 1: Test',
      );

      final map = msg.toMap();
      final reconstituted = ChatMessage.fromMap(map);

      expect(reconstituted.id, 'msg_1');
      expect(reconstituted.text, 'Test message');
      expect(reconstituted.mode, IntelligenceMode.expert);
      expect(reconstituted.thinkingProcess, 'Step 1: Test');
      expect(reconstituted.isUser, isTrue);
    });

    test('GoalMilestone serialization and toggle works', () {
      final milestone = GoalMilestone(id: 'm1', title: 'Task 1', isCompleted: false);
      expect(milestone.isCompleted, isFalse);

      milestone.isCompleted = true;
      final map = milestone.toMap();
      final fromMap = GoalMilestone.fromMap(map);

      expect(fromMap.isCompleted, isTrue);
      expect(fromMap.title, 'Task 1');
    });

    test('Conversation flags private mode correctly', () {
      final normalConv = Conversation(
        id: 'c1',
        title: 'Work',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPrivate: false,
      );

      final privateConv = Conversation(
        id: 'c2',
        title: 'Secret',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPrivate: true,
      );

      expect(normalConv.isPrivate, isFalse);
      expect(privateConv.isPrivate, isTrue);
    });

    test('BuildProject serializes files dictionary to JSON', () {
      final project = BuildProject(
        id: 'p1',
        name: 'My Web App',
        description: 'Test Project',
        files: {'index.html': '<h1>Hi</h1>'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = project.toMap();
      final restored = BuildProject.fromMap(map);

      expect(restored.files['index.html'], '<h1>Hi</h1>');
      expect(restored.name, 'My Web App');
    });
  });
}
