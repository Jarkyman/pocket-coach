import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_coach/shared/services/analytics_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SubscriptionStatus { free, pro, loading }

class SubscriptionService {
  static const String entitlementId = 'Pocket Coach Plus';
  bool _isConfigured = false;

  SubscriptionService();

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      String? apiKey;
      if (Platform.isIOS) {
        apiKey = dotenv.env['REVENUECAT_IOS_API_KEY'];
      } else if (Platform.isAndroid) {
        apiKey = dotenv.env['REVENUECAT_ANDROID_API_KEY'];
      }

      if (apiKey != null &&
          apiKey.isNotEmpty &&
          !apiKey.contains('placeholder')) {
        await Purchases.configure(PurchasesConfiguration(apiKey));
        _isConfigured = true;

        // Sync anonymous ID to Analytics on startup
        final customerInfo = await Purchases.getCustomerInfo();
        AnalyticsService.setUserId(customerInfo.originalAppUserId);
      } else {
        debugPrint(
          'RevenueCat: API Key is missing or placeholder. Running in unconfigured mode.',
        );
      }
    } catch (e, stack) {
      AnalyticsService.logError(
        e.toString(),
        type: 'revenuecat_init_failure',
        stackTrace: stack.toString(),
      );
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (kIsWeb) return SubscriptionStatus.pro;
    if (!_isConfigured) return SubscriptionStatus.free;

    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementId]?.isActive ?? false) {
        return SubscriptionStatus.pro;
      }
    } catch (e, stack) {
      AnalyticsService.logError(
        e.toString(),
        type: 'revenuecat_fetch_status_failure',
        stackTrace: stack.toString(),
      );
      debugPrint('Error fetching subscription status: $e');
    }
    return SubscriptionStatus.free;
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_isConfigured) return false;
    try {
      final PurchaseResult result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return result.customerInfo.entitlements.all[entitlementId]?.isActive ??
          false;
    } catch (e, stack) {
      AnalyticsService.logError(
        e.toString(),
        type: 'revenuecat_purchase_failure',
        stackTrace: stack.toString(),
      );
      debugPrint('Error purchasing package: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isConfigured) return false;
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e, stack) {
      AnalyticsService.logError(
        e.toString(),
        type: 'revenuecat_restore_failure',
        stackTrace: stack.toString(),
      );
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  Future<void> presentPaywall() async {
    if (!_isConfigured) return;
    try {
      await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
    }
  }

  Future<void> showCustomerCenter() async {
    if (!_isConfigured) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Error showing customer center: $e');
    }
  }
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, SubscriptionStatus>((
      ref,
    ) {
      final service = ref.watch(subscriptionServiceProvider);
      return SubscriptionStatusNotifier(service);
    });

class SubscriptionStatusNotifier extends StateNotifier<SubscriptionStatus> {
  final SubscriptionService _service;

  SubscriptionStatusNotifier(this._service)
    : super(SubscriptionStatus.loading) {
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    state = await _service.getSubscriptionStatus();
  }

  void setProForTesting(bool isPro) {
    state = isPro ? SubscriptionStatus.pro : SubscriptionStatus.free;
  }
}
