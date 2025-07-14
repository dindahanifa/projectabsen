
import 'dart:convert';
import 'package:projectabsen/model/absen_model.dart';
class HistoryResponse {
  final String message;
  final List<HistoryData> data;

  HistoryResponse({required this.message, required this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => HistoryData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class HistoryData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? alasanIzin;

  HistoryData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.alasanIzin,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
      checkInAddress: json['check_in_address'],
      checkOutAddress: json['check_out_address'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_date': attendanceDate,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_in_address': checkInAddress,
      'check_out_address': checkOutAddress,
      'check_in_location': checkInLocation,
      'check_out_location': checkOutLocation,
      'status': status,
      'alasan_izin': alasanIzin,
    };
  }
}