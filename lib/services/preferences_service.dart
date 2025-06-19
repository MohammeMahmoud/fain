import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;
  static const String _userKey = 'currentUser';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _firstLaunchKey = 'first_launch';

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Preferences
  static Future<bool> saveUserData(String userData) async {
    return await _prefs?.setString(_userKey, userData) ?? false;
  }

  static String? getUserData() {
    return _prefs?.getString(_userKey);
  }

  // Theme Preferences
  static Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs?.setString(_themeKey, themeMode) ?? false;
  }

  static String? getThemeMode() {
    return _prefs?.getString(_themeKey);
  }

  // Language Preferences
  static Future<bool> saveLanguage(String language) async {
    return await _prefs?.setString(_languageKey, language) ?? false;
  }

  static String? getLanguage() {
    return _prefs?.getString(_languageKey);
  }

  // Notification Preferences
  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs?.setBool(_notificationsKey, enabled) ?? false;
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsKey) ?? true;
  }

  // First Launch Check
  static Future<bool> isFirstLaunch() async {
    bool isFirst = _prefs?.getBool(_firstLaunchKey) ?? true;
    if (isFirst) {
      await _prefs?.setBool(_firstLaunchKey, false);
    }
    return isFirst;
  }

  // Clear all preferences
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  // Remove specific preference
  static Future<bool> removePreference(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
} 