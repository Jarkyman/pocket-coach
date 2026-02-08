import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  /// Standard event to track screen views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Custom event for onboarding status
  static Future<void> logOnboardingEvent(String status) async {
    await _analytics.logEvent(
      name: 'onboarding_event',
      parameters: {'status': status},
    );
  }

  /// Track coach selection
  static Future<void> logCoachSelected(String coachId, String coachName) async {
    await _analytics.logEvent(
      name: 'coach_selected',
      parameters: {'coach_id': coachId, 'coach_name': coachName},
    );
  }

  /// Track token usage for AI calls
  static Future<void> logTokensUsed(int tokens, String model) async {
    await _analytics.logEvent(
      name: 'tokens_used',
      parameters: {'count': tokens, 'model': model},
    );
  }

  /// Track paywall views
  static Future<void> logPaywallViewed(String source) async {
    await _analytics.logEvent(
      name: 'paywall_viewed',
      parameters: {'source': source},
    );
  }

  /// Generic event logger for flexibility
  static Future<void> logEvent(
    String name, [
    Map<String, Object>? params,
  ]) async {
    final sanitizedParams = params?.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value.toString());
      }
      return MapEntry(key, value);
    });
    await _analytics.logEvent(name: name, parameters: sanitizedParams);
  }

  /// Set user ID for cross-device tracking
  static Future<void> setUserId(String id) async {
    await _analytics.setUserId(id: id);
  }

  /// Set custom user properties
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Log technical errors for debugging
  static Future<void> logError(
    String message, {
    String? type,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'technical_error',
      parameters: {
        'message': message.length > 100 ? message.substring(0, 100) : message,
        'type': type ?? 'unknown',
        'stack_trace': stackTrace != null
            ? (stackTrace.length > 100
                  ? stackTrace.substring(0, 100)
                  : stackTrace)
            : 'none',
      },
    );
  }
}
