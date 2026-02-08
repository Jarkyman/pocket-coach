import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_button.dart';
import '../../../shared/ui/app_card.dart';
import '../../../shared/services/analytics_service.dart';
import '../data/coach_repository.dart';
import '../domain/coach.dart';
import '../../chat/data/chat_repository.dart';

class CoachDetailsScreen extends ConsumerWidget {
  final String coachId;

  const CoachDetailsScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesProvider);
    final theme = Theme.of(context);

    // Find the coach from the list cache (assumes loaded)
    final coach = coachesAsync.asData?.value.firstWhere(
      (c) => c.id == coachId,
      orElse: () => throw Exception('Coach not found'),
    );

    if (coach == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Log details view
    AnalyticsService.logCoachSelected(coachId, coach.name);

    return ProviderScope(
      overrides: [rootCoachDetailsProvider.overrideWithValue(this)],
      child: AppScaffold(
        appBar: const AppTopBar(title: ''),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Preview Style',
                    style: AppButtonStyle.secondary,
                    onPressed: () => _showPreview(context, coach),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: AppButton(
                    label: 'Start Chat',
                    onPressed: () => _handleStartChat(context, ref, coach),
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            100,
          ), // Add bottom padding for scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'coach-${coach.id}',
                flightShuttleBuilder:
                    (
                      BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext,
                    ) {
                      final Widget toHero = toHeroContext.widget;
                      return Material(
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: toHero,
                        ),
                      );
                    },
                child: AppCard(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: AssetImage(coach.imagePath),
                        ),
                        const Gap(16),
                        Text(
                          coach.name,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(8),
                        Text(
                          coach.oneLiner,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(32),
              _DetailSection(title: 'Style', content: coach.style, delay: 100),
              const Gap(24),
              _DetailSection(
                title: 'Method',
                content: coach.method.join('\n• '),
                delay: 200,
              ),
              const Gap(24),
              _DetailSection(
                title: 'Rules',
                content: coach.rules.join('\n• '),
                delay: 300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStartChat(
    BuildContext context,
    WidgetRef ref,
    Coach coach,
  ) async {
    final repo = ref.read(chatRepositoryProvider);
    final conversations = repo.getConversations(coach.id);

    String conversationId;
    if (conversations.isEmpty) {
      // Create new - will be saved on first message
      conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      // Resume latest
      conversationId = conversations.first.id;
    }

    if (context.mounted) {
      AnalyticsService.logEvent('chat_started', {
        'coach_id': coach.id,
        'coach_name': coach.name,
        'is_new': conversations.isEmpty,
      });
      context.pushReplacement('/home/coach/${coach.id}/chat/$conversationId');
    }
  }

  void _showPreview(BuildContext context, Coach coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PreviewSheet(coach: coach),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final int delay;

  const _DetailSection({
    required this.title,
    required this.content,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const Gap(8),
        Text(content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 10, end: 0);
  }
}

class _PreviewSheet extends ConsumerWidget {
  final Coach coach;

  const _PreviewSheet({required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Conversation Preview', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const Gap(24),
          _ChatBubble(text: coach.previewExample['user']!, isUser: true),
          const Gap(16),
          _ChatBubble(text: coach.previewExample['assistant']!, isUser: false),
          const Gap(40),
          AppButton(
            label: 'Start Chat with ${coach.name}',
            onPressed: () {
              context.pop();
              final parent = ref.read(rootCoachDetailsProvider);
              parent._handleStartChat(context, ref, coach);
            },
          ),
          const Gap(20),
        ],
      ),
    );
  }
}

// Helper to access CoachDetailsScreen logic from sub-widgets
final rootCoachDetailsProvider = Provider<CoachDetailsScreen>(
  (ref) => throw UnimplementedError(),
);

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: isUser ? 32 : 0, right: isUser ? 0 : 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: isUser ? null : const Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
