import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _loginKey = "login";
  static const String _tokenKey = "token";

  static void saveLogin(bool login) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_loginKey, login);
  }

  static void saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool? login = prefs.getBool(_loginKey) ?? false;
    return login;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    return token;
  }

  static void deleteLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_loginKey);
  }
}