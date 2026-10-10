import 'dart:async';
import '../models/chat_message.dart';
import '../models/intelligence_mode.dart';
import '../models/training_memory.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/training_repository.dart';
import '../../data/services/offline_ai_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SendMessageUseCase {
  final ChatRepository _chatRepository;
  final TrainingRepository _trainingRepository;
  final OfflineAiService _offlineAiService;

  SendMessageUseCase({
    required ChatRepository chatRepository,
    required TrainingRepository trainingRepository,
    OfflineAiService? offlineAiService,
  })  : _chatRepository = chatRepository,
        _trainingRepository = trainingRepository,
        _offlineAiService = offlineAiService ?? OfflineAiService();

  Future<ChatMessage> execute({
    required String conversationId,
    required String prompt,
    required IntelligenceMode mode,
    bool isPrivate = false,
    List<String> attachedFiles = const [],
  }) async {
    final now = DateTime.now();

    // 1. Create and save user message
    final userMsg = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch}_u',
      conversationId: conversationId,
      sender: 'user',
      text: prompt,
      mode: mode,
      timestamp: now,
      isTemporary: isPrivate,
      attachedFiles: attachedFiles.isNotEmpty ? attachedFiles : null,
    );
    await _chatRepository.saveMessage(userMsg);

    // 2. Fetch active on-device memories (if not in private mode)
    final memories = isPrivate ? <TrainingMemory>[] : await _trainingRepository.getMemories();

    // 3. Check connectivity state
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = !connectivity.contains(ConnectivityResult.none);

    // 4. Fetch conversation history for multi-turn context
    final history = await _chatRepository.getMessages(conversationId, isPrivate: isPrivate);

    // 5. Generate response with full conversation context
    final aiResult = await _offlineAiService.generateResponse(
      prompt: prompt,
      mode: mode,
      activeMemories: memories,
      conversationId: isPrivate ? null : conversationId,
      isOnline: isOnline,
      attachedFiles: attachedFiles,
      conversationHistory: history,
    );

    // 5. Create assistant message
    final assistantMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_a',
      conversationId: conversationId,
      sender: 'elynos',
      text: aiResult.text,
      thinkingProcess: aiResult.thinkingProcess,
      mode: mode,
      timestamp: DateTime.now(),
      imageUrl: aiResult.generatedImageUrl,
      codeArtifact: aiResult.codeArtifact,
      goalMilestones: aiResult.goalMilestones,
      isTemporary: isPrivate,
      visualAudit: aiResult.visualAudit?.toJson(),
    );

    await _chatRepository.saveMessage(assistantMsg);
    return assistantMsg;
  }
}
