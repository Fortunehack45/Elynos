import 'package:flutter/material.dart';
import '../../../../domain/models/intelligence_mode.dart';
import '../../../../domain/models/chat_message.dart';
import '../../../../domain/models/conversation.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/training_repository.dart';
import '../../../../domain/use_cases/send_message_use_case.dart';

class HomeViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final TrainingRepository _trainingRepository;
  late final SendMessageUseCase _sendMessageUseCase;

  HomeViewModel({
    ChatRepository? chatRepository,
    TrainingRepository? trainingRepository,
  })  : _chatRepository = chatRepository ?? ChatRepository(),
        _trainingRepository = trainingRepository ?? TrainingRepository() {
    _sendMessageUseCase = SendMessageUseCase(
      chatRepository: _chatRepository,
      trainingRepository: _trainingRepository,
    );
    init();
  }

  // --- State ---
  int _activeTopTab = 0; // 0: Ask, 1: Imagine, 2: Build
  int get activeTopTab => _activeTopTab;

  IntelligenceMode _currentMode = IntelligenceMode.fast;
  IntelligenceMode get currentMode => _currentMode;

  bool _isPrivateMode = false;
  bool get isPrivateMode => _isPrivateMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _activeConversationId;
  String? get activeConversationId => _activeConversationId;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // --- Initialization ---
  Future<void> init() async {
    await loadConversations();
    if (_conversations.isNotEmpty) {
      await selectConversation(_conversations.first.id);
    } else {
      await startNewConversation();
    }
  }

  Future<void> loadConversations() async {
    _conversations = await _chatRepository.getConversations();
    notifyListeners();
  }

  // --- Tab & Mode Selection ---
  void setTopTab(int index) {
    _activeTopTab = index;
    if (index == 2) {
      _currentMode = IntelligenceMode.build;
    } else if (_currentMode == IntelligenceMode.build) {
      _currentMode = IntelligenceMode.fast;
    }
    notifyListeners();
  }

  void setMode(IntelligenceMode mode) {
    _currentMode = mode;
    if (mode == IntelligenceMode.build) {
      _activeTopTab = 2;
    }
    notifyListeners();
  }

  void togglePrivateMode() {
    _isPrivateMode = !_isPrivateMode;
    if (_isPrivateMode) {
      _chatRepository.clearPrivateMessages();
      _messages = [];
    } else {
      if (_activeConversationId != null) {
        selectConversation(_activeConversationId!);
      }
    }
    notifyListeners();
  }

  // --- Conversations Management ---
  Future<void> startNewConversation() async {
    _activeTopTab = 0;
    if (_isPrivateMode) {
      _chatRepository.clearPrivateMessages();
      _messages = [];
      notifyListeners();
      return;
    }

    _activeConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    _messages = [];
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    try {
      _activeConversationId = id;
      _isPrivateMode = false;
      _activeTopTab = 0; // CRITICAL: Always switch to Chat tab so past messages render immediately!
      final loaded = await _chatRepository.getMessages(id, isPrivate: false);
      _messages = List.from(loaded);
    } catch (e) {
      debugPrint('Error selecting conversation $id: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String id) async {
    await _chatRepository.deleteConversation(id);
    await loadConversations();
    if (_activeConversationId == id) {
      if (_conversations.isNotEmpty) {
        await selectConversation(_conversations.first.id);
      } else {
        await startNewConversation();
      }
    }
  }

  // --- Message Sending ---
  Future<void> sendMessage(String text, {List<String> attachedFiles = const []}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachedFiles.isEmpty) return;
    String promptText = trimmed.isEmpty ? 'Inspect and process attached file(s)' : trimmed;

    if (_activeTopTab == 1) {
      final l = promptText.toLowerCase();
      if (!l.contains('generate image') && !l.contains('draw') && !l.contains('picture of') && !l.contains('paint')) {
        promptText = 'Generate image of $promptText';
      }
    }

    final convId = _isPrivateMode
        ? 'private_session'
        : (_activeConversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}');

    _activeConversationId ??= convId;

    // 1. Optimistic Update: Immediately display user message in the chat
    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_u',
      conversationId: convId,
      sender: 'user',
      text: promptText,
      mode: _currentMode,
      timestamp: DateTime.now(),
      isTemporary: _isPrivateMode,
      attachedFiles: attachedFiles.isNotEmpty ? List.from(attachedFiles) : null,
    );
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      // 2. Safe conversation title update
      if (!_isPrivateMode) {
        final title = promptText.length > 28 ? '${promptText.substring(0, 28)}...' : promptText;
        final conv = _conversations.where((c) => c.id == convId).firstOrNull;
        if (conv != null) {
          conv.title = title;
          await _chatRepository.saveConversation(conv);
        } else {
          final newConv = Conversation(
            id: convId,
            title: title,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _chatRepository.saveConversation(newConv);
        }
      }

      // 3. Generate response via use case
      final aiMsg = await _sendMessageUseCase.execute(
        conversationId: convId,
        prompt: promptText,
        mode: _currentMode,
        isPrivate: _isPrivateMode,
        attachedFiles: attachedFiles,
      );

      // 4. Update messages with AI response
      if (!_messages.any((m) => m.id == aiMsg.id)) {
        _messages.add(aiMsg);
      }

      await loadConversations();
    } catch (e, stack) {
      debugPrint('Error in sendMessage: $e\n$stack');
      _messages.add(ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: convId,
        sender: 'elynos',
        text: '### ⚡ Elynos 1 Axiom\n\n'
            'Encountered an issue processing on-device: `$e`\n\n'
            'The engine is operational. Please try your prompt again.',
        mode: _currentMode,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
