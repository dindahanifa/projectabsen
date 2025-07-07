import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectabsen/utils/endpoint.dart';
import 'package:projectabsen/model/user_model.dart';
import 'package:projectabsen/utils/shared_prefences.dart';

class UserService {
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String password,
    required int batchId,
    required int trainingId,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "batch_id": batchId.toString(),
        "training_id": trainingId.toString(),
      },
    );

    print("Status: \${response.statusCode}");
    print("Body: \${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserResponse.fromJson(jsonResponse).toJson();
    } else if (response.statusCode == 422) {
      return UserResponse.fromJson(jsonResponse).toJson();
    } else {
      throw Exception("Gagal registrasi: \${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.login),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    print("Status: \${response.statusCode}");
    print("Body: \${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userResponse = UserResponse.fromJson(jsonResponse);
      final token = userResponse.data?.token;
      final userId = userResponse.data?.user?.id;

      if (token != null && userId != null) {
        await PreferenceHandler.saveToken(token);
        await PreferenceHandler.saveUserId(userId);
        await PreferenceHandler.saveLogin(true);
        print("Token: \$token");
        print("UserId: \$userId");
      }

      return userResponse.toJson();
    } else if (response.statusCode == 422) {
      return UserResponse.fromJson(jsonResponse).toJson();
    } else {
      print("Login gagal: \${response.statusCode}");
      throw Exception("Login gagal: \${response.statusCode}");
    }
  }
}
