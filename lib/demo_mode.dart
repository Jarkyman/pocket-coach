import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/domain/chat_message.dart';
import 'features/chat/domain/conversation.dart';

class DemoMode {
  static const _uuid = Uuid();

  static Future<void> init(ChatRepository chatRepo) async {
    // Only run if the flag is set
    const isDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
    if (!isDemoMode) return;

    // Hide status bar and navigation bar for clean screenshots
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    debugPrint('🚀 DEMO MODE ACTIVATED: Resetting and seeding data...');

    // 1. Clear all existing conversations locally
    // Since chatRepo doesn't expose a clearAll, we fetch and delete one by one
    final allConvos = chatRepo.getAllConversations();
    for (final convo in allConvos) {
      await chatRepo.deleteConversation(convo.id);
    }

    // 2. Seed Conversations
    await _seedProductivityCoach(chatRepo);
    await _seedFounderCoach(chatRepo);
    await _seedCreativeCoach(chatRepo);

    debugPrint('✅ DEMO MODE: Data seeding complete.');
  }

  static Future<void> _seedProductivityCoach(ChatRepository repo) async {
    final convoId = _uuid.v4();
    final now = DateTime.now();

    // Conversation
    final convo = Conversation(
      id: convoId,
      coachId: 'productivity_coach',
      startTime: now.subtract(const Duration(minutes: 10)),
      lastUpdated: now,
      lastMessage:
          "Here is your plan: 1. Update team (15m). 2. Prep slides (45m). Go.",
    );
    await repo.saveConversation(convo);

    // Messages
    final messages = [
      ChatMessage(
        id: _uuid.v4(),
        text:
            "I have a big meeting in an hour and I'm not ready. Help me plan.",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 5)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Deep breath. What is the SINGLE most important outcome of this meeting?",
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 4)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text: "The client needs to approve the new budget.",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 2)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Here is your plan:\n1. Update team on changes (15m).\n2. Prep the budget slides (45m).\n\nFocus only on the numbers. Go.",
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 1)),
        conversationId: convoId,
      ),
    ];

    for (final msg in messages) {
      await repo.saveMessage(msg);
    }
  }

  static Future<void> _seedFounderCoach(ChatRepository repo) async {
    final convoId = _uuid.v4();
    final now = DateTime.now().subtract(const Duration(hours: 2));

    // Conversation
    final convo = Conversation(
      id: convoId,
      coachId: 'founder_coach',
      startTime: now.subtract(const Duration(minutes: 20)),
      lastUpdated: now,
      lastMessage:
          "MVP Definition: A simple weekly menu PDF. No app yet. Test demand first.",
    );
    await repo.saveConversation(convo);

    // Messages
    final messages = [
      ChatMessage(
        id: _uuid.v4(),
        text: "I want to build a meal delivery app for busy parents.",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 15)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Classic mistake: building the app before the business. What is the MVP that requires ZERO code?",
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 14)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text: "Maybe just emailing a PDF menu and taking Venmo payments?",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 5)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Exactly. That is your MVP.\n\nGoal: Sell 10 subscriptions this week manually.\nIf they won't pay for the PDF, they won't pay for the app.",
        isUser: false,
        timestamp: now,
        conversationId: convoId,
      ),
    ];

    for (final msg in messages) {
      await repo.saveMessage(msg);
    }
  }

  static Future<void> _seedCreativeCoach(ChatRepository repo) async {
    final convoId = _uuid.v4();
    final now = DateTime.now().subtract(const Duration(days: 1));

    // Conversation
    final convo = Conversation(
      id: convoId,
      coachId: 'creative_coach',
      startTime: now.subtract(const Duration(minutes: 30)),
      lastUpdated: now,
      lastMessage:
          "Idea: A 'Coupon Book' of experiences. 'One home-cooked dinner', 'Movie night choice'.",
    );
    await repo.saveConversation(convo);

    // Messages
    final messages = [
      ChatMessage(
        id: _uuid.v4(),
        text:
            "I need a budget-friendly gift idea for my partner. Something handmade.",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 10)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Time > Money. Let's brainstorm experiences instead of things. What do they complain about doing?",
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 8)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text: "Doing the dishes and deciding what to watch on TV.",
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 2)),
        conversationId: convoId,
      ),
      ChatMessage(
        id: _uuid.v4(),
        text:
            "Perfect.\n\nMake a 'Coupon Book' of experiences:\n• 'One dish-free evening'\n• 'Movie night veto card'\n• 'Breakfast in bed'\n\nUse nice paper and a ribbon. It's personal and solves their pain points.",
        isUser: false,
        timestamp: now,
        conversationId: convoId,
      ),
    ];

    for (final msg in messages) {
      await repo.saveMessage(msg);
    }
  }
}
