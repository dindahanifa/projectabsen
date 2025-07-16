import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:projectabsen/model/lupaPassword_request.dart';
import 'package:projectabsen/model/reset_password.dart';
import 'package:projectabsen/model/user_model.dart';
import 'package:projectabsen/model/profil_model.dart';
import 'package:projectabsen/model/registererror_model.dart';
import 'package:projectabsen/utils/endpoint.dart';
import 'package:projectabsen/utils/shared_prefences.dart';

class UserService {

  // Daftar Akun
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String password,
    required String jenisKelamin,
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
        "jenis_kelamin": jenisKelamin,
        "batch_id": batchId.toString(),
        "training_id": trainingId.toString(),
      },
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserResponse.fromJson(jsonResponse).toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      throw Exception("Gagal registrasi: ${response.statusCode}");
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.login),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userResponse = UserResponse.fromJson(jsonResponse);
      final token = userResponse.data?.token;
      final user = userResponse.data?.user;

      if (token != null && user != null) {
        await PreferenceHandler.saveToken(token);
        await PreferenceHandler.saveUserId(user.id ?? 0);
        await PreferenceHandler.saveLogin(true);
        await PreferenceHandler.saveUsername(user.name ?? '');
        await PreferenceHandler.saveProfilePhoto(user.profilePhoto?.toString() ?? '');
        await PreferenceHandler.saveBatchId(user.batchId ?? 0);
        await PreferenceHandler.saveTrainingId(user.trainingId ?? 0);

        print("✅ Login berhasil");
        print("Token: $token");
        print("User ID: ${user.id}");
      }

      return userResponse.toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      print("Login gagal: ${response.statusCode}");
      throw Exception("Login gagal: ${response.statusCode}");
    }
  }

  // Ambil Profil
  Future<Map<String, dynamic>> getProfile() async {
    try {
      String? token = await PreferenceHandler.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse(Endpoint.profil),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = userProfileFromJson(response.body).toJson();
        return body;
      } else if (response.statusCode == 422) {
        return registerErrorResponseFromJson(response.body).toJson();
      } else {
        throw Exception("Gagal mengambil profil: ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ ERROR getProfile: $e");
      print(stack);
      rethrow;
    }
  }

  // Perbarui Profil
  Future<Map<String, dynamic>> updateProfile(String name) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.put(
      Uri.parse(Endpoint.profil),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {'name': name},
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      return userResponseFromJson(response.body).toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      throw Exception("Gagal memperbarui profil: ${response.statusCode}");
    }
  }

  // Perbarui foto profil
  Future<Map<String, dynamic>> updatePhotoProfile(File imageFile) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileExtension = path.extension(imageFile.path).toLowerCase().replaceAll('.', '');
      final body = jsonEncode({
        'profile_photo': base64Image,
        'file_extension': fileExtension,
      });

      final response = await http.put(
        Uri.parse(Endpoint.updatePhotoProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 422) {
        return registerErrorResponseFromJson(response.body).toJson();
      } else {
        throw Exception("Gagal update foto profil: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ERROR updatePhotoProfile: $e");
      rethrow;
    }
  }

  // Lupa Password
  Future<LupaPasswordResponse> forgotPassword(String email) async {
  final response = await http.post(
    Uri.parse(Endpoint.lupaPassword),
    headers: {"Accept": "application/json"},
    body: {"email": email},
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");

  final jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final jsonResponse = jsonDecode(response.body);
    return LupaPasswordResponse.fromJson(jsonResponse);
  } else if (response.statusCode == 422) {
    final jsonResponse = jsonDecode(response.body);
    throw Exception(jsonResponse['message'] ?? "Permintaan tidak valid");
  } else {
    throw Exception("Gagal kirim permintaan reset password: ${response.statusCode}");
  }
}

  // Reset Password
  Future<ResetPasswordResponse> resetPassword(ResetPasswordRequest request) async {
    final response = await http.post(
      Uri.parse(Endpoint.resetPassword),
      headers: {"Accept": "application/json"},
      body: request.toJson(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ResetPasswordResponse.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? "Gagal reset password");
    }
  }
}
