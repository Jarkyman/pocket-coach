import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_controller.dart';
import '../application/subscription_service.dart';
import '../../../shared/services/analytics_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logPaywallViewed('direct');
  }

  void _safePop() {
    if (_isPopping) return;
    if (context.mounted && context.canPop()) {
      _isPopping = true;
      context.pop();
    }
  }

  void _handleSuccess() {
    // Refresh status
    ref.read(subscriptionStatusProvider.notifier).refreshStatus();
    AnalyticsService.logEvent('purchase_success');

    // Safely pop using a microtask to avoid Navigator locks
    Future.microtask(() => _safePop());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final brightness = themeMode == ThemeMode.dark
        ? Brightness.dark
        : themeMode == ThemeMode.light
        ? Brightness.light
        : MediaQuery.platformBrightnessOf(context);

    final themeData = themeMode == ThemeMode.dark
        ? AppTheme.darkTheme
        : themeMode == ThemeMode.light
        ? AppTheme.lightTheme
        : Theme.of(context);

    return Scaffold(
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(platformBrightness: brightness),
        child: Theme(
          data: themeData,
          child: PaywallView(
            onPurchaseCompleted: (customerInfo, storeProduct) =>
                _handleSuccess(),
            onRestoreCompleted: (customerInfo) => _handleSuccess(),
            onDismiss: () => _safePop(),
          ),
        ),
      ),
    );
  }
}
