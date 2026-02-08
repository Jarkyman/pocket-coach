import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/app_top_bar.dart';
import '../../../shared/ui/app_card.dart';
import '../../../app/theme/theme_controller.dart';
import '../../monetization/application/subscription_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: const AppTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ThemeOption(
                  label: 'System',
                  mode: ThemeMode.system,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _ThemeOption(
                  label: 'Light',
                  mode: ThemeMode.light,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _ThemeOption(
                  label: 'Dark',
                  mode: ThemeMode.dark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const Gap(32),
          Text('Personalization', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: Text('My Topics', style: theme.textTheme.bodyLarge),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/onboarding/topics'),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                ListTile(
                  title: Text('Edit Context', style: theme.textTheme.bodyLarge),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/onboarding/values'),
                ),
              ],
            ),
          ),
          const Gap(32),
          Text('Chat Storage', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _StorageOption(
                  label: 'Delete after 10 days',
                  days: 10,
                  selected:
                      ref.watch(settingsControllerProvider).chatCleanupDays ==
                      10,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setChatCleanupDays(10),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _StorageOption(
                  label: 'Delete after 30 days',
                  days: 30,
                  selected:
                      ref.watch(settingsControllerProvider).chatCleanupDays ==
                      30,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setChatCleanupDays(30),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _StorageOption(
                  label: 'Delete after 90 days',
                  days: 90,
                  selected:
                      ref.watch(settingsControllerProvider).chatCleanupDays ==
                      90,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setChatCleanupDays(90),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _StorageOption(
                  label: 'Never delete',
                  days: null,
                  selected:
                      ref.watch(settingsControllerProvider).chatCleanupDays ==
                      null,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setChatCleanupDays(null),
                ),
              ],
            ),
          ),
          const Gap(32),
          Text('Subscription', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ref.watch(subscriptionStatusProvider) == SubscriptionStatus.pro
                    ? ListTile(
                        title: Text(
                          'Manage Subscription',
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: const Text('Customer Center'),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => ref
                            .read(subscriptionServiceProvider)
                            .showCustomerCenter(),
                      )
                    : ListTile(
                        title: Text(
                          'Upgrade to Pro',
                          style: theme.textTheme.bodyLarge,
                        ),
                        trailing: const Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                        ),
                        onTap: () => context.push('/paywall'),
                      ),
              ],
            ),
          ),
          const Gap(32),
          Text('Legal & Support', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Privacy Policy',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => launchUrl(
                    Uri.parse(
                      'https://hartvigsolutions.com/?privacypolicy=true#pocket-coach',
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                ListTile(
                  title: Text(
                    'Terms of Service',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => launchUrl(
                    Uri.parse(
                      'https://hartvigsolutions.com/?termsofservice=true#pocket-coach',
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                ListTile(
                  title: Text(
                    'Support Email',
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: const Text('support@hartvigsolutions.com'),
                  trailing: const Icon(Icons.mail_outline, size: 20),
                  onTap: () => launchUrl(
                    Uri.parse('mailto:support@hartvigsolutions.com'),
                  ),
                ),
              ],
            ),
          ),
          const Gap(32),
          Text('About', style: theme.textTheme.titleMedium),
          const Gap(16),
          AppCard(
            child: Text(
              'PocketCoach v1.0.0\nDesigned for clarity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageOption extends StatelessWidget {
  final String label;
  final int? days;
  final bool selected;
  final VoidCallback onTap;

  const _StorageOption({
    required this.label,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
