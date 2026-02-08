import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_button.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/services/analytics_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.spa_rounded, size: 64, color: theme.colorScheme.primary)
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),

            const Gap(32),

            Text(
                  'PocketCoach',
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .moveY(begin: 20, end: 0, curve: Curves.easeOut),

            const Gap(16),

            Text(
                  'Minimalist coaching for\nclarity and focus.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .moveY(begin: 10, end: 0),

            const Spacer(),

            AppButton(
                  label: 'Get Started',
                  onPressed: () {
                    AnalyticsService.logOnboardingEvent('started');
                    context.go('/onboarding/topics');
                  },
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .moveY(begin: 20, end: 0),

            const Gap(48),
          ],
        ),
      ),
    );
  }
}
