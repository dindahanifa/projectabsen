import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _loginKey = "login";
  static const String _tokenKey = "token";
  static const String _userIdKey = "user_id";
  static const String _usernameKey = "username";
  static const String _batchIdKey = "batch_id";
  static const String _trainingIdKey = "training_id";
  static const String _profileImageKey = "profile_image";

  // ✅ LOGIN STATUS
  static Future<void> saveLogin(bool login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, login);
  }

  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // ✅ TOKEN
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ✅ USER ID
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // ✅ USERNAME / NAME
  static Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, name);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // ✅ BATCH ID
  static Future<void> saveBatchId(int batchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_batchIdKey, batchId);
  }

  static Future<int?> getBatchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_batchIdKey);
  }

  // ✅ TRAINING ID
  static Future<void> saveTrainingId(int trainingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trainingIdKey, trainingId);
  }

  static Future<int?> getTrainingId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_trainingIdKey);
  }

  // ✅ PROFILE PHOTO
  static Future<void> saveProfilePhoto(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, url);
  }

  static Future<String?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  // ✅ HAPUS SEMUA (Logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_batchIdKey);
    await prefs.remove(_trainingIdKey);
    await prefs.remove(_profileImageKey);
  }
}
