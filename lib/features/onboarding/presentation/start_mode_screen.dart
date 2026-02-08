import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_card.dart';

class StartModeScreen extends StatelessWidget {
  const StartModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppTopBar(title: 'How would you like to start?'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ModeCard(
              title: 'Pick a Coach',
              description: 'Browse our library of expert AI coaches.',
              icon: Icons.people_outline,
              onTap: () => context.go('/home'),
              delay: 0,
            ),
            const Gap(16),
            _ModeCard(
              title: 'Pick a Topic',
              description: 'Find a coach based on a specific challenge.',
              icon: Icons.topic_outlined,
              onTap: () =>
                  context.go('/home'), // Simplifying for MVP to go to Library
              delay: 100,
            ),
            const Gap(16),
            _ModeCard(
              title: 'Create Your Own',
              description: 'Design a custom coach tailored to you.',
              icon: Icons.add_circle_outline,
              isLocked: true,
              onTap: () {},
              delay: 200,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLocked;
  final int delay;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isLocked = false,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.disabledColor.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isLocked
                      ? theme.disabledColor
                      : theme.colorScheme.primary,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isLocked
                                ? theme.disabledColor
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isLocked) ...[
                          const Gap(8),
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: theme.disabledColor,
                          ),
                        ],
                      ],
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .moveX(begin: 20, end: 0, curve: Curves.easeOut);
  }
}
