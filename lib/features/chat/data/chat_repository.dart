import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';

class ChatRepository {
  static const String _messagesBoxName = 'chat_messages';
  static const String _conversationsBoxName = 'conversations';

  final Box<ChatMessage> _messagesBox;
  final Box<Conversation> _conversationsBox;

  ChatRepository({
    required Box<ChatMessage> messagesBox,
    required Box<Conversation> conversationsBox,
  })  : _messagesBox = messagesBox,
        _conversationsBox = conversationsBox;

  static Future<ChatRepository> init() async {
    final messagesBox = await Hive.openBox<ChatMessage>(_messagesBoxName);
    final conversationsBox = await Hive.openBox<Conversation>(_conversationsBoxName);
    return ChatRepository(
      messagesBox: messagesBox,
      conversationsBox: conversationsBox,
    );
  }

  // Conversations
  Conversation? getConversation(String id) {
    return _conversationsBox.get(id);
  }

  List<Conversation> getAllConversations() {
    return _conversationsBox.values.toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  List<Conversation> getConversations(String coachId) {
    return _conversationsBox.values
        .where((c) => c.coachId == coachId)
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  Stream<List<Conversation>> watchConversations(String coachId) async* {
    yield getConversations(coachId);
    await for (final _ in _conversationsBox.watch()) {
      yield getConversations(coachId);
    }
  }

  Future<void> saveConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  Future<void> deleteConversation(String id) async {
    await _conversationsBox.delete(id);
    // Delete all messages associated with this conversation
    final keysToDelete = _messagesBox.values
        .where((m) => m.conversationId == id)
        .map((m) => m.id)
        .toList();
    await _messagesBox.deleteAll(keysToDelete);
  }

  // Messages
  List<ChatMessage> getMessages(String conversationId) {
    return _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _messagesBox.put(message.id, message);
    
    // Update conversation last message/time
    final conversation = _conversationsBox.get(message.conversationId);
    if (conversation != null) {
      await saveConversation(conversation.copyWith(
        lastMessage: message.text,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  // Cleanup logic
  Future<void> purgeOldConversations(int days) async {
    final threshold = DateTime.now().subtract(Duration(days: days));
    final toDelete = _conversationsBox.values
        .where((c) => c.lastUpdated.isBefore(threshold))
        .map((c) => c.id)
        .toList();

    for (final id in toDelete) {
      await deleteConversation(id);
    }
  }

  // Usage tracking
  int getTotalUserMessageCount() {
    return _messagesBox.values.where((m) => m.isUser).length;
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});
