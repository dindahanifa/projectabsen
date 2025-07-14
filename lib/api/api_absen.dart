import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectabsen/model/absen_co_request.dart';
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/model/absen_request.dart';
import 'package:projectabsen/model/absen_today.dart';
import 'package:projectabsen/model/ajukanIzin_request.dart';
import 'package:projectabsen/model/history_response.dart';
import 'package:projectabsen/utils/endpoint.dart';
import 'package:intl/intl.dart';

class AbsenService {
  // ✅ Check In
  static Future<AbsenModel> checkIn(AbsenRequest data, String token) async {
    final url = Uri.parse(Endpoint.checkIn);
      final bodyData = jsonEncode(data.toJson());

  print("URL: $url");
  print("Body: $bodyData");
  print("Token: $token");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data.toJson()),
    );

      print('CheckIn Response: ${response.statusCode}');
  print('CheckIn Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenResponse.fromJson(jsonResponse).data!;
    } else {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Check Out
  static Future<AbsenModel> checkOut(AbsenCoRequest data, String token) async {
    final url = Uri.parse(Endpoint.checkOut);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenResponse.fromJson(jsonResponse).data!;
    } else {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Ajukan Izin
  static Future<AbsenModel> ajukanIzin(AjukanIzinRequest data, String token) async {
    final url = Uri.parse(Endpoint.ajukanIzin);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenResponse.fromJson(jsonResponse).data!;
    } else {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Ambil Absen Hari Ini
  static Future<AbsenToday?> getAbsenToday(String token) async {
final date = 
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final url = Uri.parse("${Endpoint.absenToday}?attendance_date=$date");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
print("URL: $url");
print("Response Status: ${response.statusCode}");
print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AbsenToday.fromJson(jsonResponse["data"]);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Statistik Absensi
  static Future<StatistikAbsen> getStatistik(String token) async {
    final url = Uri.parse(Endpoint.statistik);
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final statistikResponse = StatistikResponse.fromJson(jsonResponse);

      if (statistikResponse.data != null) {
        return statistikResponse.data!;
      } else {
        throw Exception("Data statistik kosong");
      }
    } else {
      throw Exception(_parseError(response));
    }
  }

  static Future<List<HistoryData>> getRiwayatAbsen(
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
      return HistoryResponse.fromJson(jsonResponse).data ?? [];
    } else {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Hapus Absen
  static Future<void> deleteAbsen(int id, String token) async {
    final url = Uri.parse('${Endpoint.deleteAbsen}/$id');
    final response = await http.delete(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  // ✅ Parsing Error
  static String _parseError(http.Response response) {
    try {
      final jsonError = jsonDecode(response.body);
      return jsonError['message'] ?? 'Terjadi kesalahan';
    } catch (_) {
      return response.body;
    }
  }
}
