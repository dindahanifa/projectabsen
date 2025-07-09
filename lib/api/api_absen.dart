// File: absen_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/utils/endpoint.dart';

class AbsenService {
  static Future<AbsenModel> checkIn(AbsenModel data, String token) async {
    final url = Uri.parse(Endpoint.checkIn);
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
      throw Exception('Gagal Check In: ${response.body}');
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
      throw Exception('Gagal Check Out: ${response.body}');
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
      throw Exception('Gagal mengambil absen hari ini: ${response.body}');
    }
  }

  static Future<List<AbsenModel>> getRiwayatAbsen(String token, {String? startDate, String? endDate}) async {
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
      throw Exception('Gagal mengambil riwayat absen: ${response.body}');
    }
  }

  static Future<void> deleteAbsen(int id, String token) async {
    final url = Uri.parse('${Endpoint.deleteAbsen}/$id');
    final response = await http.delete(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus absen: ${response.body}');
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
      throw Exception('Gagal mengambil statistik kehadiran: ${response.body}');
    }
  }
}