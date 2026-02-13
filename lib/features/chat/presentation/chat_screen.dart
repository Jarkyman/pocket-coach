import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_text_field.dart';
import '../../../shared/services/privacy_consent_service.dart';
import '../../coaches/data/coach_repository.dart';
import '../domain/chat_message.dart';
import 'ai_consent_dialog.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String coachId;
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.coachId,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final privacyService = ref.read(privacyConsentServiceProvider);
    if (!privacyService.hasSeenConsent) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => const AIConsentDialog(),
      );

      if (agreed != true) return;
      await privacyService.setConsentGiven();
    }

    ref
        .read(
          chatProvider((
            coachId: widget.coachId,
            conversationId: widget.conversationId,
          )).notifier,
        )
        .sendMessage(text);
    _textController.clear();
  }

  void _scrollToBottom() {
    // Wait for frame to render new message/bubble
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // In reverse list, 0 is the bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(
      chatProvider((
        coachId: widget.coachId,
        conversationId: widget.conversationId,
      )),
    );
    final coachesAsync = ref.watch(coachesProvider);
    final theme = Theme.of(context);

    // Auto-scroll on new message or typing state change
    ref.listen(
      chatProvider((
        coachId: widget.coachId,
        conversationId: widget.conversationId,
      )),
      (previous, next) {
        if (previous?.messages.length != next.messages.length ||
            previous?.isTyping != next.isTyping) {
          _scrollToBottom();
        }

        // Paywall trigger
        if (next.limitReached && !(previous?.limitReached ?? false)) {
          context.push('/paywall');
        }
      },
    );

    // Find our coach directly from coachId
    final coach = coachesAsync.asData?.value
        .where((c) => c.id == widget.coachId)
        .firstOrNull;
    final title = coach?.name ?? 'Chat';

    return AppScaffold(
      appBar: AppTopBar(
        title: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () =>
                context.push('/home/chat/history/${widget.coachId}'),
          ),
        ],
      ),
      withSafeArea: false, // Handle safe area manually for full bleed input
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              // Wrap list in SafeArea
              bottom: false,
              child: chatState.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'Start a conversation with $title',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      reverse: true, // Start from bottom
                      // Reverse index access to show messages in correct order visually
                      itemCount:
                          chatState.messages.length +
                          (chatState.isTyping ? 1 : 0),
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, index) {
                        // Logic for reversed list: 0 is bottom-most item

                        // If typing, it's at index 0 (bottom)
                        if (chatState.isTyping && index == 0) {
                          return const _TypingIndicator()
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0);
                        }

                        // Calculate message index
                        // If typing, real message index is (index - 1)
                        // But we want to show LATEST message at bottom (index 0 or 1)
                        // So we simply reverse the access to the list
                        final adjustedIndex = chatState.isTyping
                            ? index - 1
                            : index;
                        final messageIndex =
                            chatState.messages.length - 1 - adjustedIndex;

                        final msg = chatState.messages[messageIndex];
                        return _MessageBubble(message: msg)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .moveY(begin: 10, end: 0);
                      },
                    ),
            ),
          ),
          _ChatInput(
            controller: _textController,
            onSend: _handleSend,
            isTyping: chatState.isTyping,
            limitReached: chatState.limitReached,
            quickPrompts: (chatState.messages.isEmpty && coach != null)
                ? coach.prompts
                : [],
            onPromptSelected: (text) {
              if (!chatState.isTyping && !chatState.limitReached) {
                _textController.text = text;
                _handleSend();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            Gap(4),
            _Dot(delay: 200),
            Gap(4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(duration: 600.ms, delay: delay.ms, begin: 0.3, end: 1.0);
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
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
        child: SelectableText(
          message.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isTyping;
  final bool limitReached;
  final List<String> quickPrompts;
  final Function(String) onPromptSelected;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isTyping,
    required this.limitReached,
    required this.quickPrompts,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We purposely do NOT use AppTextField here because we want full edge-to-edge background
    // but the inputs padded safely.
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // or surface
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (quickPrompts.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: quickPrompts.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    final prompt = quickPrompts[index];
                    return ActionChip(
                      label: Text(prompt, style: theme.textTheme.bodySmall),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      shape: const StadiumBorder(),
                      side: BorderSide.none,
                      onPressed: () => onPromptSelected(prompt),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: limitReached
                          ? 'Message limit reached'
                          : 'Type a message...',
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 500,
                      enabled: !limitReached,
                      onSubmitted: (_) =>
                          (isTyping || limitReached) ? null : onSend(),
                    ),
                  ),
                  const Gap(12),
                  IconButton.filled(
                    onPressed: (isTyping || limitReached) ? null : onSend,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.12),
                      disabledForegroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
