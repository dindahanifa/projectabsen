import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/utils/endpoint.dart';
import 'package:projectabsen/utils/shared_prefences.dart';

class absenService {
  static Future<CheckInRespon> checkIn(CheckInModel data, String token) async {
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
      return checkInResponFromJson(response.body);
    } else {
      throw Exception('Gagal Check In: ${response.body}');
    }
  }

  static Future<CheckOutRespon> checkOut(CheckOutModel data, String token) async {
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
      return checkOutResponFromJson(response.body);
    } else {
      throw Exception('Gagal Check Out: ${response.body}');
    }
  }

    static Future<KehadiranModel> getKehadiranTerbaru(String token) async {
    final checkInUrl = Uri.parse(Endpoint.checkIn);
    final checkOutUrl = Uri.parse(Endpoint.checkOut);

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final checkInResponse = await http.get(checkInUrl, headers: headers);
    final checkOutResponse = await http.get(checkOutUrl, headers: headers);

    if (checkInResponse.statusCode == 200) {
      final checkIn = CheckInModel.fromJson(jsonDecode(checkInResponse.body));

      CheckOutModel? checkOut;
      if (checkOutResponse.statusCode == 200 && checkOutResponse.body.isNotEmpty) {
        checkOut = CheckOutModel.fromJson(jsonDecode(checkOutResponse.body));
      }

      return KehadiranModel(checkIn: checkIn, checkOut: checkOut);
    } else {
      throw Exception('Gagal mengambil kehadiran terbaru');
    }
  }

  static Future<KehadiranModel> getAbsenToday(String token) async {
    final checkInUrl = Uri.parse(Endpoint.checkIn);
    final checkOutUrl = Uri.parse(Endpoint.checkOut);

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final checkInResponse = await http.get(checkInUrl, headers: headers);
    final checkOutResponse = await http.get(checkOutUrl, headers: headers);

    if (checkInResponse.statusCode == 200) {
      final checkIn = CheckInModel.fromJson(jsonDecode(checkInResponse.body));

      CheckOutModel? checkOut;
      if (checkOutResponse.statusCode == 200 && checkOutResponse.body.isNotEmpty) {
        checkOut = CheckOutModel.fromJson(jsonDecode(checkOutResponse.body));
      }

      return KehadiranModel(checkIn: checkIn, checkOut: checkOut);
    } else {
      throw Exception('Gagal mengambil absen hari ini');
    }
  }

  static Future<StatistikKehadiran> getStatistik(String token) async {
    final url = Uri.parse(Endpoint.statistik);

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return StatistikKehadiran.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil statistik kehadiran');
    }
  }
}

