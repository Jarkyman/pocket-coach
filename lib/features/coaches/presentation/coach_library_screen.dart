import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_card.dart';
import '../../onboarding/presentation/context_controller.dart';
import '../data/coach_repository.dart';
import '../domain/coach.dart';
import '../../chat/data/chat_repository.dart';
import '../../monetization/application/monetization_config.dart';
import '../../monetization/application/subscription_service.dart';

class CoachLibraryScreen extends ConsumerWidget {
  const CoachLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesProvider);

    return AppScaffold(
      appBar: AppTopBar(
        title: 'Library',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: coachesAsync.when(
        data: (coaches) => _CoachList(coaches: coaches),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CoachList extends ConsumerWidget {
  final List<Coach> coaches;

  const _CoachList({required this.coaches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userContext = ref.watch(contextControllerProvider);
    final userTopics = userContext.topics;

    // Filter logic
    final recommended = coaches
        .where((c) => c.topics.any((t) => userTopics.contains(t)))
        .toList();

    // If no recommendations (or no topics selected), showing all is fine.
    // But if we have recommendations, we show them at the top.

    // Split into Recommended and All.
    // If recommended is empty, we just show one list.
    if (recommended.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: coaches.length,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (context, index) {
          final coach = coaches[index];
          return _CoachCard(coach: coach)
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 300.ms)
              .moveY(begin: 10, end: 0, curve: Curves.easeOut);
        },
      );
    }

    // Otherwise, show sections
    final otherCoaches = coaches
        .where((c) => !recommended.contains(c))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended for You',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          ...recommended.map(
            (coach) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CoachCard(coach: coach),
            ),
          ),

          if (otherCoaches.isNotEmpty) ...[
            const Gap(32),
            Text('Explore More', style: theme.textTheme.titleMedium),
            const Gap(16),
            ...otherCoaches.map(
              (coach) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CoachCard(coach: coach),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoachCard extends ConsumerWidget {
  final Coach coach;

  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscription = ref.watch(subscriptionStatusProvider);
    final isFree = MonetizationConfig.isCoachFree(coach.id);
    final isLocked = subscription == SubscriptionStatus.free && !isFree;

    return Hero(
      tag: 'coach-${coach.id}',
      child: AppCard(
        onTap: () {
          if (isLocked) {
            context.push('/paywall');
          } else {
            context.push('/home/coach/${coach.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(coach.imagePath),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      const Gap(12),
                      Flexible(
                        child: Text(
                          coach.name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLocked) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final isSaved = ref
                        .watch(contextControllerProvider)
                        .savedCoachIds
                        .contains(coach.id);
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isSaved
                            ? Colors.red
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                      ),
                      onPressed: () {
                        ref
                            .read(contextControllerProvider.notifier)
                            .toggleSavedCoach(coach.id);
                      },
                    );
                  },
                ),
              ],
            ),
            const Gap(8),
            Text(
              coach.oneLiner,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: coach.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Gap(8),
                TextButton.icon(
                  onPressed: () => _handleDirectChat(context, ref),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Chat'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDirectChat(BuildContext context, WidgetRef ref) {
    final subscription = ref.read(subscriptionStatusProvider);
    final isFree = MonetizationConfig.isCoachFree(coach.id);
    final isLocked = subscription == SubscriptionStatus.free && !isFree;

    if (isLocked) {
      context.push('/paywall');
      return;
    }

    final chatRepo = ref.read(chatRepositoryProvider);
    final conversations = chatRepo.getConversations(coach.id);

    String conversationId;
    if (conversations.isEmpty) {
      conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      conversationId = conversations.first.id;
    }

    context.push('/home/coach/${coach.id}/chat/$conversationId');
  }
}
