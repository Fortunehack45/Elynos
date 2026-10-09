import 'dart:async';
import '../../domain/models/conversation.dart';
import '../../domain/models/chat_message.dart';
import '../services/local_database_service.dart';

class ChatRepository {
  final LocalDatabaseService _dbService;

  ChatRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService();

  // In-memory store for Private/Incognito chats (Zero persistence)
  final List<ChatMessage> _privateMessages = [];

  Future<List<Conversation>> getConversations() async {
    return await _dbService.getConversations();
  }

  Future<void> saveConversation(Conversation conversation) async {
    if (!conversation.isPrivate) {
      await _dbService.saveConversation(conversation);
    }
  }

  Future<void> deleteConversation(String id) async {
    await _dbService.deleteConversation(id);
  }

  Future<List<ChatMessage>> getMessages(String conversationId, {bool isPrivate = false}) async {
    if (isPrivate) {
      return List.unmodifiable(_privateMessages);
    }
    return await _dbService.getMessages(conversationId);
  }

  Future<void> saveMessage(ChatMessage message) async {
    if (message.isTemporary) {
      _privateMessages.add(message);
    } else {
      await _dbService.saveMessage(message);
    }
  }

  void clearPrivateMessages() {
    _privateMessages.clear();
  }
}
