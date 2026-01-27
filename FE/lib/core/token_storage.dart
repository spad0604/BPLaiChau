import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _roleKey = 'auth_role';
  static const String _rememberMeKey = 'auth_remember_me';

  String? token;
  String? username;
  String? role;

  /// Initialize and load saved credentials from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      
      if (rememberMe) {
        token = prefs.getString(_tokenKey);
        username = prefs.getString(_usernameKey);
        role = prefs.getString(_roleKey);
      }
    } catch (e) {
      // Ignore SharedPreferences errors on web initial load
      // This can happen if storage is not available
      print('TokenStorage init error: $e');
    }
  }

  /// Save credentials to SharedPreferences
  Future<void> save({required bool rememberMe}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      
      if (rememberMe) {
        if (token != null) await prefs.setString(_tokenKey, token!);
        if (username != null) await prefs.setString(_usernameKey, username!);
        if (role != null) await prefs.setString(_roleKey, role!);
      } else {
        await prefs.remove(_tokenKey);
        await prefs.remove(_usernameKey);
        await prefs.remove(_roleKey);
      }
    } catch (e) {
      print('TokenStorage save error: $e');
    }
  }

  /// Clear all credentials
  Future<void> clear() async {
    token = null;
    username = null;
    role = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_rememberMeKey);
    } catch (e) {
      print('TokenStorage clear error: $e');
    }
  }

  /// Check if user has valid token
  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

