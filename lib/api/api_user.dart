import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:projectabsen/model/profil_model.dart';
import 'package:projectabsen/model/registererror_model.dart';
import 'package:projectabsen/utils/endpoint.dart';
import 'package:projectabsen/model/user_model.dart';
import 'package:projectabsen/utils/shared_prefences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class UserService {
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
      return UserResponse.fromJson(jsonResponse).toJson();
    } else {
      throw Exception("Gagal registrasi: ${response.statusCode}");
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

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userResponse = UserResponse.fromJson(jsonResponse);
      final token = userResponse.data?.token;
      final userId = userResponse.data?.user?.id;

      if (token != null && userId != null) {
        await PreferenceHandler.saveToken(token);
        await PreferenceHandler.saveUserId(userId);
        await PreferenceHandler.saveLogin(true);
        print("Token: $token");
        print("UserId: $userId");
      }

      return userResponse.toJson();
    } else if (response.statusCode == 422) {
      return UserResponse.fromJson(jsonResponse).toJson();
    } else {
      print("Login gagal: ${response.statusCode}");
      throw Exception("Login gagal: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      String? token = await PreferenceHandler.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

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

        print("✅ Profil berhasil diambil");
        print("DEBUG profile data (full): $body");

        final user = body['data'] ?? body;
        print("DEBUG training_id: ${user['training_id']}");

        return body;
      } else if (response.statusCode == 422) {
        return registerErrorResponseFromJson(response.body).toJson();
      } else {
        print("Gagal mengambil profil: ${response.statusCode}");
        throw Exception("Gagal mengambil profil: ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ ERROR getProfile: $e");
      print(stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang');
    }
    final response = await http.put(
      Uri.parse(Endpoint.profil),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {'name': name},
    );
    print(response.body);

    if (response.statusCode == 200) {
      return userResponseFromJson(response.body).toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      print("Gagal memperbarui profil: ${response.statusCode}");
      throw Exception("Gagal memperbarui profil: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> updatePhotoProfile(File imageFile) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang');
    }

    final ext = path.extension(imageFile.path).toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == '.png') {
      mimeType = 'image/png';
    } else if (ext == '.jpg' || ext == '.jpeg') {
      mimeType = 'image/jpeg';
    } else if (ext == '.gif') {
      mimeType = 'image/gif';
    }

    var uri = Uri.parse(Endpoint.updatePhotoProfile);
    var request = http.MultipartRequest('PUT', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    var multipartFile = await http.MultipartFile.fromPath(
      'profile_photo',
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    print('File path: ${imageFile.path}');
    print('File size (bytes): ${imageFile.lengthSync()}');
    print('Field name: profile_photo');
    print('Mime type: $mimeType');
    print('Jumlah file dalam request: ${request.files.length}');

    var response = await request.send();

    var responseData = await response.stream.bytesToString();

    print('Response status: ${response.statusCode}');
    print('Response body: $responseData');

    if (response.statusCode == 200) {
      print('Foto profil berhasil diupdate: $responseData');
      return jsonDecode(responseData);
    } else if (response.statusCode == 422) {
      var errorJson = jsonDecode(responseData);
      print('Error 422 details: $errorJson');
      throw Exception('Validasi gagal: ${errorJson['message'] ?? responseData}');
    } else {
      print('Gagal update foto profil: ${response.statusCode}');
      print('Response: $responseData');
      throw Exception('Gagal update foto profil: ${response.statusCode}');
    }
  }
}
