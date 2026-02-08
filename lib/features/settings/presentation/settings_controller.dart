import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final int? chatCleanupDays;

  SettingsState({this.chatCleanupDays = 30}); // Default 30 days
}

class SettingsController extends StateNotifier<SettingsState> {
  final Box _box;

  SettingsController(this._box) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final days = _box.get('chatCleanupDays', defaultValue: 30);
    state = SettingsState(chatCleanupDays: days == 0 ? null : days);
  }

  Future<void> setChatCleanupDays(int? days) async {
    await _box.put('chatCleanupDays', days ?? 0);
    state = SettingsState(chatCleanupDays: days);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final box = Hive.box('settings');
  return SettingsController(box);
});
