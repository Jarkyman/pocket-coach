import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_button.dart';
import '../../../shared/ui/app_text_field.dart';
import '../../../shared/services/analytics_service.dart';
import 'context_controller.dart';

class ValuesScreen extends ConsumerStatefulWidget {
  const ValuesScreen({super.key});

  @override
  ConsumerState<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends ConsumerState<ValuesScreen> {
  late final TextEditingController _goalsController;
  late final TextEditingController _valuesController;
  late final TextEditingController _challengesController;

  @override
  void initState() {
    super.initState();
    // Pre-fill if existing data exists
    final currentContext = ref.read(contextControllerProvider);
    _goalsController = TextEditingController(text: currentContext.goals);
    _valuesController = TextEditingController(text: currentContext.values);
    _challengesController = TextEditingController(
      text: currentContext.challenges,
    );
  }

  @override
  void dispose() {
    _goalsController.dispose();
    _valuesController.dispose();
    _challengesController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    await ref
        .read(contextControllerProvider.notifier)
        .saveContext(
          goals: _goalsController.text.trim(),
          values: _valuesController.text.trim(),
          challenges: _challengesController.text.trim(),
        );
    await ref.read(contextControllerProvider.notifier).completeOnboarding();
    AnalyticsService.logOnboardingEvent('completed');

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = ref
        .watch(contextControllerProvider)
        .hasCompletedOnboarding;

    return AppScaffold(
      appBar: AppTopBar(
        title: isEditMode ? 'Edit Context' : 'Add Context',
        actions: [
          if (!isEditMode)
            TextButton(
              onPressed: () async {
                await ref
                    .read(contextControllerProvider.notifier)
                    .completeOnboarding();
                if (context.mounted) context.go('/home');
              },
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode
                  ? 'Update your details to help your coaches stay aligned with your progress.'
                  : 'Help your coaches understand you better. This is optional.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Gap(32),
            _Section(
              title: 'Core Values',
              hint: 'e.g. Integrity, Freedom, Growth',
              controller: _valuesController,
              delay: 0,
            ),
            const Gap(24),
            _Section(
              title: 'Current Goals',
              hint: 'e.g. Launch app, run marathon',
              controller: _goalsController,
              delay: 100,
            ),
            const Gap(24),
            _Section(
              title: 'Constraints',
              hint: 'e.g. Limited time, tight budget',
              controller: _challengesController,
              delay: 200,
            ),
            const Gap(48),
            AppButton(
              label: isEditMode ? 'Save Changes' : 'Save & Continue',
              onPressed: _handleSave,
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String hint;
  final int delay;
  final TextEditingController controller;

  const _Section({
    required this.title,
    required this.hint,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const Gap(8),
        AppTextField(hintText: hint, maxLines: 2, controller: controller),
      ],
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 10, end: 0);
  }
}
