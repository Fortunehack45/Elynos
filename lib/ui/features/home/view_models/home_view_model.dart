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
    if (_isPrivateMode) {
      _chatRepository.clearPrivateMessages();
      _messages = [];
      notifyListeners();
      return;
    }

    final newConv = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _chatRepository.saveConversation(newConv);
    _activeConversationId = newConv.id;
    _messages = [];
    await loadConversations();
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    _activeConversationId = id;
    _isPrivateMode = false;
    _messages = await _chatRepository.getMessages(id, isPrivate: false);
    notifyListeners();
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
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final convId = _isPrivateMode
        ? 'private_session'
        : (_activeConversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}');

    _isLoading = true;
    notifyListeners();

    try {
      // If first message in conversation, update title
      if (!_isPrivateMode && _messages.isEmpty && _activeConversationId != null) {
        final title = trimmed.length > 28 ? '${trimmed.substring(0, 28)}...' : trimmed;
        final conv = _conversations.firstWhere((c) => c.id == _activeConversationId);
        conv.title = title;
        await _chatRepository.saveConversation(conv);
      }

      await _sendMessageUseCase.execute(
        conversationId: convId,
        prompt: trimmed,
        mode: _currentMode,
        isPrivate: _isPrivateMode,
      );

      // Refresh messages
      _messages = await _chatRepository.getMessages(convId, isPrivate: _isPrivateMode);
      await loadConversations();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
