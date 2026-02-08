import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_button.dart';
import '../../../shared/ui/app_chip.dart';
import '../../../shared/services/analytics_service.dart';
import 'context_controller.dart';

class TopicsScreen extends ConsumerStatefulWidget {
  const TopicsScreen({super.key});

  @override
  ConsumerState<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends ConsumerState<TopicsScreen> {
  final List<String> _topics = [
    'Productivity',
    'Deep Work',
    'Stress & Anxiety',
    'Decision Making',
    'Habits',
    'Leadership',
    'Creativity',
    'Relationships',
    'Career Growth',
    'Mindfulness',
  ];

  late final Set<String> _selectedTopics;

  @override
  void initState() {
    super.initState();
    // Load existing topics if any
    final currentTopics = ref.read(contextControllerProvider).topics;
    _selectedTopics = currentTopics.toSet();
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _handleContinue() async {
    final controller = ref.read(contextControllerProvider.notifier);
    await controller.saveContext(topics: _selectedTopics.toList());
    AnalyticsService.logEvent('onboarding_topics_selected', {
      'count': _selectedTopics.length,
      'topics': _selectedTopics.toList(),
    });

    if (mounted) {
      final isCompleted = ref
          .read(contextControllerProvider)
          .hasCompletedOnboarding;
      if (isCompleted) {
        context.go('/home');
      } else {
        context.go('/onboarding/values');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: const AppTopBar(title: 'What brings you here?'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a few topics to help us recommend the right coaches.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Gap(32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _topics.asMap().entries.map((entry) {
                      final index = entry.key;
                      final topic = entry.value;
                      return AppChip(
                            label: topic,
                            isSelected: _selectedTopics.contains(topic),
                            onSelected: (_) => _toggleTopic(topic),
                          )
                          .animate()
                          .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            curve: Curves.easeOutBack,
                          );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppButton(
              label: ref.watch(contextControllerProvider).hasCompletedOnboarding
                  ? 'Save'
                  : 'Continue',
              onPressed: _selectedTopics.isNotEmpty ? _handleContinue : null,
            ).animate().fadeIn(delay: 600.ms),
          ),
        ],
      ),
    );
  }
}
