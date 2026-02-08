import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeThemeService {
  static const _channel = MethodChannel('com.hartvigsolutions.app/theme');

  static Future<void> sync(ThemeMode mode) async {
    try {
      final String themeString = _modeToString(mode);
      await _channel.invokeMethod('setTheme', {'theme': themeString});
    } catch (e) {
      debugPrint('Error syncing theme to native: $e');
    }
  }

  static String _modeToString(ThemeMode mode) {
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
