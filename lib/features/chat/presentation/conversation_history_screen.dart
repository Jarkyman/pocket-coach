import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_card.dart';
import '../../coaches/data/coach_repository.dart';
import '../data/chat_repository.dart';
import '../domain/conversation.dart';
import 'chat_controller.dart';

class ConversationHistoryScreen extends ConsumerWidget {
  final String coachId;

  const ConversationHistoryScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesProvider);
    final conversationsAsync = ref.watch(conversationsProvider(coachId));
    final theme = Theme.of(context);
    
    final coach = coachesAsync.asData?.value.firstWhere((c) => c.id == coachId);

    return AppScaffold(
      appBar: AppTopBar(title: '${coach?.name ?? "Coach"} History'),
      body: conversationsAsync.when(
        data: (conversations) => conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                    const Gap(16),
                    Text('No chat history yet', style: theme.textTheme.bodyLarge),
                    const Gap(32),
                    ElevatedButton.icon(
                      onPressed: () => _startNewChat(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Start New Chat'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: conversations.length + 1, // +1 for the "Start New" button
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AppCard(
                      onTap: () => _startNewChat(context),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
                          const Gap(12),
                          Text('Start a new session', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                        ],
                      ),
                    );
                  }

                  final conversation = conversations[index - 1];
                  return _ConversationItem(conversation: conversation);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _startNewChat(BuildContext context) async {
    final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    if (context.mounted) {
      context.go('/home/coach/$coachId/chat/$conversationId');
    }
  }
}

class _ConversationItem extends ConsumerWidget {
  final Conversation conversation;

  const _ConversationItem({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, HH:mm').format(conversation.lastUpdated);

    return AppCard(
      onTap: () => context.go('/home/coach/${conversation.coachId}/chat/${conversation.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          const Gap(4),
          Text(
            conversation.lastMessage ?? 'Empty conversation',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text('This will permanently remove all messages in this chat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(chatRepositoryProvider).deleteConversation(conversation.id);
    }
  }
}
