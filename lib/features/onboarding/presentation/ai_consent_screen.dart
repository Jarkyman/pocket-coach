import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_button.dart';
import '../../../shared/services/analytics_service.dart';
import '../../../shared/services/privacy_consent_service.dart';
import 'context_controller.dart';

class AiConsentScreen extends ConsumerWidget {
  const AiConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: const AppTopBar(title: 'Data & Privacy', actions: []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PocketCoach uses a third-party AI service to generate coaching responses.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ).animate().fadeIn(duration: 400.ms).moveY(begin: 10, end: 0),
            const Gap(24),
            Text('What data is sent:', style: theme.textTheme.titleMedium)
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(12),
            const _BulletPoint(text: 'Your chat messages')
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const _BulletPoint(text: 'The coach persona you select')
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const _BulletPoint(text: 'Any personal context you provided')
                .animate()
                .fadeIn(delay: 250.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(24),
            Text(
                  'Sent to: OpenAI.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(32),
            Text(
                  'By continuing, you acknowledge and agree to share this data with our AI provider to enable the core coaching functionality of the app.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(24),
            Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(8),
                    InkWell(
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://hartvigsolutions.com/?privacypolicy=true#pocket-coach',
                        ),
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(16),
            Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(8),
                    InkWell(
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://hartvigsolutions.com/?termsofservice=true#pocket-coach',
                        ),
                      ),
                      child: Text(
                        'Terms of Service',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .moveY(begin: 10, end: 0),
            const Gap(64),
            AppButton(
                  label: 'I Accept and Continue',
                  onPressed: () async {
                    await ref
                        .read(privacyConsentServiceProvider)
                        .setConsentGiven();
                    await ref
                        .read(contextControllerProvider.notifier)
                        .completeOnboarding();
                    AnalyticsService.logOnboardingEvent('completed');
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms)
                .moveY(begin: 20, end: 0),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyLarge),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
