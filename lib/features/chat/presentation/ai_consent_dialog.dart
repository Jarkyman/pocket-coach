import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class AIConsentDialog extends StatelessWidget {
  const AIConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('About AI Processing'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PocketCoach uses a third-party AI service to generate responses. To do this, we send:',
            style: theme.textTheme.bodyMedium,
          ),
          const Gap(12),
          _buildBulletPoint(
            context,
            'Your chat messages and the coach you select',
          ),
          const Gap(4),
          _buildBulletPoint(
            context,
            'Any context you choose to include (if applicable)',
          ),
          const Gap(12),
          Text(
            'Sent to: OpenAI.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          InkWell(
            onTap: () => launchUrl(
              Uri.parse(
                'https://hartvigsolutions.com/?privacypolicy=true#pocket-coach',
              ),
            ),
            child: Text(
              'Learn more in our Privacy Policy.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('I Agree'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: theme.textTheme.bodyMedium),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
