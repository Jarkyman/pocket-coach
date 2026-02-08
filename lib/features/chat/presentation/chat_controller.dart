import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dart_openai/dart_openai.dart';
import '../../coaches/data/coach_repository.dart';
import '../../onboarding/presentation/context_controller.dart';
import '../data/ai_service.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';
import '../../monetization/application/subscription_service.dart';
import '../../monetization/application/monetization_config.dart';

// State for Chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool limitReached;

  ChatState({
    required this.messages,
    this.isTyping = false,
    this.limitReached = false,
  });
}

class ChatController extends StateNotifier<ChatState> {
  final String coachId;
  final String conversationId;
  final Ref ref;

  ChatController({
    required this.coachId,
    required this.conversationId,
    required this.ref,
  }) : super(ChatState(messages: [])) {
    _loadMessages();
  }

  void _loadMessages() {
    final repo = ref.read(chatRepositoryProvider);
    final messages = repo.getMessages(conversationId);
    state = ChatState(messages: messages);
  }

  void sendMessage(String text) async {
    final subscription = ref.read(subscriptionStatusProvider);
    final repo = ref.read(chatRepositoryProvider);

    // Check message limit for free users
    if (subscription == SubscriptionStatus.free) {
      final totalMessages = repo.getTotalUserMessageCount();
      if (totalMessages >= MonetizationConfig.freeMessageLimit) {
        state = ChatState(
          messages: state.messages,
          isTyping: false,
          limitReached: true,
        );
        return;
      }
    }

    // Lazy save conversation if it's the first message
    final existing = repo.getConversation(conversationId);
    if (existing == null) {
      final newConversation = Conversation(
        id: conversationId,
        coachId: coachId,
        startTime: DateTime.now(),
        lastUpdated: DateTime.now(),
        lastMessage: text,
      );
      await repo.saveConversation(newConversation);
    }

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );

    // Optimistic UI update & Persistence
    state = ChatState(messages: [...state.messages, userMsg], isTyping: true);
    await repo.saveMessage(userMsg);

    String responseText;
    try {
      responseText = await _generateResponse();
    } on AiException catch (e) {
      responseText = e.message;
    } catch (e) {
      responseText = "An unexpected error occurred. Please try again.";
    }

    final aiMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );

    state = ChatState(messages: [...state.messages, aiMsg], isTyping: false);
    await repo.saveMessage(aiMsg);
  }

  Future<String> _generateResponse() async {
    final coachesAsync = ref.read(coachesProvider);
    final coach = coachesAsync.value?.firstWhere(
      (c) => c.id == coachId,
      orElse: () => throw Exception('Coach not found'),
    );

    if (coach == null) return "I'm having trouble connecting right now.";

    final userContext = ref.read(contextControllerProvider);
    final aiService = ref.read(aiServiceProvider);

    // Build System Prompt (Condensed)
    final String systemPrompt =
        """
You are ${coach.name}. Role: ${coach.oneLiner}. Style: ${coach.style}.
Core: ${coach.method.join(', ')}. Rules: ${coach.rules.join(', ')}.
User Context: Goals: ${userContext.goals}, Values: ${userContext.values}, Challenges: ${userContext.challenges}.
Rules: 1. Conversational. 2. No principle headers. 3. Concise. 4. One thing at a time. 5. End with a short question. 6. Stay in character.
""";

    // Build Messages History (Last 10 messages OR 2000 chars total for cost control)
    int charCount = 0;
    final history = <OpenAIChatCompletionChoiceMessageModel>[];

    // Take messages starting from most recent
    final recentMessages = state.messages.reversed.take(10).toList();
    for (final m in recentMessages) {
      if (charCount + m.text.length > 2000) break;
      charCount += m.text.length;

      history.insert(
        0,
        OpenAIChatCompletionChoiceMessageModel(
          role: m.isUser
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(m.text),
          ],
        ),
      );
    }

    return await aiService.getResponse(
      systemPrompt: systemPrompt,
      messages: history,
    );
  }
}

final chatProvider =
    StateNotifierProvider.family<
      ChatController,
      ChatState,
      ({String coachId, String conversationId})
    >(
      (ref, arg) => ChatController(
        coachId: arg.coachId,
        conversationId: arg.conversationId,
        ref: ref,
      ),
    );

final conversationsProvider = StreamProvider.family<List<Conversation>, String>(
  (ref, coachId) {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.watchConversations(coachId);
  },
);
