import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _loginKey = "login";
  static const String _tokenKey = "token";
  static const String _userIdKey = "user_id";

  // Simpan status login (true/false)
  static Future<void> saveLogin(bool login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, login);
  }

  // Ambil status login
  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Simpan userId
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  // Ambil userId
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Hapus status login
  static Future<void> deleteLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
  }

  // Hapus token
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Hapus userId
  static Future<void> deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}