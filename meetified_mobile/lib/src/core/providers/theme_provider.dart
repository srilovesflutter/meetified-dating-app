import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    try {
      String savedTheme = LocalStorageService.getThemeMode();
      LoggerService.log('ThemeNotifier', '_loadThemeMode', 'Loaded theme: $savedTheme');
      
      switch (savedTheme) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
        default:
          state = ThemeMode.system;
          break;
      }
    } catch (e) {
      LoggerService.error('ThemeNotifier', '_loadThemeMode', 'Failed to load theme: $e');
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      state = themeMode;
      
      String themeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await LocalStorageService.saveThemeMode(themeString);
      LoggerService.log('ThemeNotifier', 'setThemeMode', 'Theme changed to: $themeString');
    } catch (e) {
      LoggerService.error('ThemeNotifier', 'setThemeMode', 'Failed to save theme: $e');
    }
  }

  AppThemeMode get appThemeMode {
    switch (state) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

// Providers
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // This is a simplified version - in a real app you'd need context
  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      // Default to light for provider without context
      return false;
  }
});

// Extension for easy theme access
extension ThemeExtension on BuildContext {
  bool get isDarkMode {
    final themeMode = Theme.of(this).brightness;
    return themeMode == Brightness.dark;
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}