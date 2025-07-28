import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

class LocalStorageService {
  static late Box _box;
  static late SharedPreferences _prefs;
  
  static Future<void> initialize() async {
    try {
      LoggerService.log('LocalStorageService', 'initialize', 'Initializing local storage');
      
      _box = await Hive.openBox('meetified_box');
      _prefs = await SharedPreferences.getInstance();
      
      LoggerService.success('LocalStorageService', 'initialize', 'Local storage initialized');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'initialize', 'Failed to initialize: $e');
      rethrow;
    }
  }
  
  // Generic methods for Hive
  static Future<void> setValue(String key, dynamic value) async {
    try {
      await _box.put(key, value);
      LoggerService.log('LocalStorageService', 'setValue', 'Saved key: $key');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'setValue', 'Failed to save $key: $e');
      rethrow;
    }
  }
  
  static T? getValue<T>(String key, [T? defaultValue]) {
    try {
      return _box.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      LoggerService.error('LocalStorageService', 'getValue', 'Failed to get $key: $e');
      return defaultValue;
    }
  }
  
  static Future<void> deleteValue(String key) async {
    try {
      await _box.delete(key);
      LoggerService.log('LocalStorageService', 'deleteValue', 'Deleted key: $key');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'deleteValue', 'Failed to delete $key: $e');
      rethrow;
    }
  }
  
  // Generic methods for SharedPreferences
  static Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      LoggerService.log('LocalStorageService', 'setString', 'Saved string key: $key');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'setString', 'Failed to save string $key: $e');
      rethrow;
    }
  }
  
  static String? getString(String key, [String? defaultValue]) {
    try {
      return _prefs.getString(key) ?? defaultValue;
    } catch (e) {
      LoggerService.error('LocalStorageService', 'getString', 'Failed to get string $key: $e');
      return defaultValue;
    }
  }
  
  static Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      LoggerService.log('LocalStorageService', 'setBool', 'Saved bool key: $key');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'setBool', 'Failed to save bool $key: $e');
      rethrow;
    }
  }
  
  static bool getBool(String key, [bool defaultValue = false]) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      LoggerService.error('LocalStorageService', 'getBool', 'Failed to get bool $key: $e');
      return defaultValue;
    }
  }
  
  // App-specific methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setValue(AppConstants.userDataKey, userData);
  }
  
  static Map<String, dynamic>? getUserData() {
    return getValue<Map<String, dynamic>>(AppConstants.userDataKey);
  }
  
  static Future<void> saveThemeMode(String themeMode) async {
    await setString(AppConstants.themeKey, themeMode);
  }
  
  static String getThemeMode() {
    return getString(AppConstants.themeKey, 'system') ?? 'system';
  }
  
  static Future<void> setOnboardingCompleted(bool completed) async {
    await setBool(AppConstants.onboardingKey, completed);
  }
  
  static bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingKey, false);
  }
  
  static Future<void> setPremiumStatus(bool isPremium) async {
    await setBool(AppConstants.premiumKey, isPremium);
  }
  
  static bool isPremiumUser() {
    return getBool(AppConstants.premiumKey, false);
  }
  
  static Future<void> clearAllData() async {
    try {
      await _box.clear();
      await _prefs.clear();
      LoggerService.log('LocalStorageService', 'clearAllData', 'Cleared all local data');
    } catch (e) {
      LoggerService.error('LocalStorageService', 'clearAllData', 'Failed to clear data: $e');
      rethrow;
    }
  }
}