import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PrivacyConsentService {
  final Box _box;
  static const String _consentKey = 'hasSeenAIConsent';

  PrivacyConsentService(this._box);

  bool get hasSeenConsent => _box.get(_consentKey, defaultValue: false);

  Future<void> setConsentGiven() async {
    await _box.put(_consentKey, true);
  }
}

final privacyConsentServiceProvider = Provider<PrivacyConsentService>((ref) {
  final box = Hive.box('settings');
  return PrivacyConsentService(box);
});
