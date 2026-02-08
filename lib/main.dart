import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'features/onboarding/data/context_repository.dart';
import 'features/chat/domain/chat_message.dart';
import 'features/chat/domain/conversation.dart';
import 'features/chat/data/chat_repository.dart';

import 'demo_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Init Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Register Adapters
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ConversationAdapter());

  final contextRepo = await ContextRepository.init();
  final chatRepo = await ChatRepository.init();

  // Run chat cleanup based on settings
  final settingsBox = await Hive.openBox('settings');
  final cleanupDays = settingsBox.get('chatCleanupDays', defaultValue: 30);
  if (cleanupDays != 0) {
    await chatRepo.purgeOldConversations(cleanupDays);
  }

  // Check for Demo Mode seeding
  await DemoMode.init(chatRepo);

  runApp(
    ProviderScope(
      overrides: [
        contextRepositoryProvider.overrideWithValue(contextRepo),
        chatRepositoryProvider.overrideWithValue(chatRepo),
      ],
      child: const PocketCoachApp(),
    ),
  );
}
