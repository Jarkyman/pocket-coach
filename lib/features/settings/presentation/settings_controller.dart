import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings_controller.g.dart';

class SettingsState {
  final int? chatCleanupDays;

  SettingsState({this.chatCleanupDays = 30}); // Default 30 days
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() {
    final box = Hive.box('settings');
    final days = box.get('chatCleanupDays', defaultValue: 30);
    return SettingsState(chatCleanupDays: days == 0 ? null : days);
  }

  Future<void> setChatCleanupDays(int? days) async {
    final box = Hive.box('settings');
    await box.put('chatCleanupDays', days ?? 0);
    state = SettingsState(chatCleanupDays: days);
  }
}
