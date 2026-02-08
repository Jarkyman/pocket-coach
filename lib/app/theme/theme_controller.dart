import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/services/native_theme_service.dart';

class ThemeController extends Notifier<ThemeMode> {
  static const _boxName = 'settings';
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final box = Hive.box(_boxName);
    final savedMode = box.get(_key, defaultValue: 'system') as String;
    final mode = _parseMode(savedMode);

    // Sync to native on startup
    NativeThemeService.sync(mode);

    return mode;
  }

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;

    // Sync to native for RevenueCat & other components
    NativeThemeService.sync(mode);

    final box = Hive.box(_boxName);
    box.put(_key, _modeToString(mode));
  }

  ThemeMode _parseMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
