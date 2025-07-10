import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/utils/endpoint.dart';

class AbsenService {
  static Future<AbsenModel> checkIn(
    AbsenModel data,
    String token, {
    File? imageFile,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);

    if (imageFile == null) {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AbsenResponse.fromJson(jsonResponse).data!;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception('Gagal Check In: ${errorResponse['message'] ?? response.body}');
      }
    } else {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['status'] = data.status
        ..fields['check_in_lat'] = data.checkInLat.toString()
        ..fields['check_in_lng'] = data.checkInLng.toString()
        ..fields['check_in_address'] = data.checkInAddress ?? ''
        ..fields['created_at'] = data.createdAt.toIso8601String()
        ..fields['updated_at'] = data.updatedAt.toIso8601String();

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AbsenResponse.fromJson(jsonResponse).data!;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception('Gagal Check In (foto): ${errorResponse['message'] ?? response.body}');
      }
    }
  }

  static Future<AbsenModel> checkOut(AbsenModel data, String token) async {
    final url = Uri.parse(Endpoint.checkOut);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenResponse.fromJson(jsonResponse).data!;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal Check Out: ${errorResponse['message'] ?? response.body}');
    }
  }

  static Future<AbsenModel?> getAbsenToday(String token) async {
    final url = Uri.parse(Endpoint.absenToday);
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenModel.fromJson(jsonResponse['data']);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal mengambil absen hari ini: ${errorResponse['message'] ?? response.body}');
    }
  }

  static Future<List<AbsenModel>> getRiwayatAbsen(
    String token, {
    String? startDate,
    String? endDate,
  }) async {
    final uri = Uri.parse(Endpoint.riwayatAbsen).replace(queryParameters: {
      if (startDate != null) 'start': startDate,
      if (endDate != null) 'end': endDate,
    });

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List list = jsonResponse['data'];
      return list.map((e) => AbsenModel.fromJson(e)).toList();
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal mengambil riwayat absen: ${errorResponse['message'] ?? response.body}');
    }
  }

  static Future<void> deleteAbsen(int id, String token) async {
    final url = Uri.parse('${Endpoint.deleteAbsen}/$id');
    final response = await http.delete(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal menghapus absen: ${errorResponse['message'] ?? response.body}');
    }
  }

  static Future<StatistikKehadiran> getStatistik(String token) async {
    final url = Uri.parse(Endpoint.statistik);
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return StatistikKehadiran.fromJson(jsonResponse['data']);
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal mengambil statistik kehadiran: ${errorResponse['message'] ?? response.body}');
    }
  }

  static Future<AbsenModel> ajukanIzin(AbsenModel data, String token) async {
    final url = Uri.parse(Endpoint.ajukanIzin);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenResponse.fromJson(jsonResponse).data!;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Gagal mengajukan izin: ${errorResponse['message'] ?? response.body}');
    }
  }
}
