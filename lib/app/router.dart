import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/topics_screen.dart';
import '../../features/onboarding/presentation/start_mode_screen.dart';
import '../../features/onboarding/presentation/values_screen.dart';
import '../../features/coaches/presentation/coach_library_screen.dart';
import '../../features/coaches/presentation/coach_details_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/conversation_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/monetization/presentation/paywall_screen.dart';

import '../../features/onboarding/data/context_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final contextRepo = ref.watch(contextRepositoryProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding/welcome',
    redirect: (context, state) {
      final userContext = contextRepo.getContext();
      final isCompleted = userContext?.hasCompletedOnboarding ?? false;
      final isAtWelcome = state.uri.path == '/onboarding/welcome';
      
      if (isCompleted && isAtWelcome) {
        return '/home';
      }
      return null;
    },
    routes: [
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/topics',
      builder: (context, state) => const TopicsScreen(),
    ),
    GoRoute(
      path: '/onboarding/start',
      builder: (context, state) => const StartModeScreen(),
    ),
    GoRoute(
      path: '/onboarding/values',
      builder: (context, state) => const ValuesScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const CoachLibraryScreen(),
      routes: [
        GoRoute(
          path: 'chat/history/:coachId',
          builder: (context, state) {
            final coachId = state.pathParameters['coachId']!;
            return ConversationHistoryScreen(coachId: coachId);
          },
        ),
        GoRoute(
          path: 'coach/:coachId/chat/:conversationId',
          builder: (context, state) {
            final coachId = state.pathParameters['coachId']!;
            final conversationId = state.pathParameters['conversationId']!;
            return ChatScreen(coachId: coachId, conversationId: conversationId);
          },
        ),
        GoRoute(
          path: 'coach/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CoachDetailsScreen(coachId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/paywall',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: PaywallScreen(),
      ),
    ),
  ],
);
});
