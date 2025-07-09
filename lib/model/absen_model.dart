// File: absen_model.dart
import 'dart:convert';

// Absen Model Umum

class AbsenModel {
  final int id;
  final int userId;
  final String status; 
  final String? alasanIzin;

  final DateTime? checkIn;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;

  final DateTime? checkOut;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkOutLocation;
  final String? checkOutAddress;

  final DateTime createdAt;
  final DateTime updatedAt;

  AbsenModel({
    required this.id,
    required this.userId,
    required this.status,
    this.alasanIzin,
    this.checkIn,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutLocation,
    this.checkOutAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbsenModel.fromJson(Map<String, dynamic> json) {
    return AbsenModel(
      id: json['id'],
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      status: json['status'],
      alasanIzin: json['alasan_izin'],

      checkIn: json['check_in'] != null ? DateTime.tryParse(json['check_in']) : null,
      checkInLat: json['check_in_lat'] != null ? double.tryParse(json['check_in_lat'].toString()) : null,
      checkInLng: json['check_in_lng'] != null ? double.tryParse(json['check_in_lng'].toString()) : null,
      checkInLocation: json['check_in_location'],
      checkInAddress: json['check_in_address'],

      checkOut: json['check_out'] != null ? DateTime.tryParse(json['check_out']) : null,
      checkOutLat: json['check_out_lat'] != null ? double.tryParse(json['check_out_lat'].toString()) : null,
      checkOutLng: json['check_out_lng'] != null ? double.tryParse(json['check_out_lng'].toString()) : null,
      checkOutLocation: json['check_out_location'],
      checkOutAddress: json['check_out_address'],

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'status': status,
        'alasan_izin': alasanIzin,
        'check_in': checkIn?.toIso8601String(),
        'check_in_lat': checkInLat,
        'check_in_lng': checkInLng,
        'check_in_location': checkInLocation,
        'check_in_address': checkInAddress,
        'check_out': checkOut?.toIso8601String(),
        'check_out_lat': checkOutLat,
        'check_out_lng': checkOutLng,
        'check_out_location': checkOutLocation,
        'check_out_address': checkOutAddress,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class AbsenResponse {
  final String message;
  final AbsenModel? data;

  AbsenResponse({
    required this.message,
    this.data,
  });

  factory AbsenResponse.fromJson(Map<String, dynamic> json) {
    return AbsenResponse(
      message: json['message'],
      data: json['data'] != null ? AbsenModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data?.toJson(),
      };
}

class StatistikKehadiran {
  final int hadir;
  final int izin;
  final int total;

  StatistikKehadiran({
    required this.hadir,
    required this.izin,
    required this.total,
  });

  factory StatistikKehadiran.fromJson(Map<String, dynamic> json) {
    return StatistikKehadiran(
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hadir': hadir,
        'izin': izin,
        'total': total,
      };
}

class AbsenTodayModel {
  final DateTime tanggal;
  final DateTime? jamMasuk;
  final DateTime? jamKeluar;
  final String alamatMasuk;
  final String alamatKeluar;
  final String status;
  final String? alasanIzin;

  AbsenTodayModel({
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    required this.alamatMasuk,
    required this.alamatKeluar,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenTodayModel.fromJson(Map<String, dynamic> json) {
    return AbsenTodayModel(
      tanggal: DateTime.parse(json['tanggal']),
      jamMasuk: json['jam_masuk'] != null ? DateTime.tryParse(json['jam_masuk']) : null,
      jamKeluar: json['jam_keluar'] != null ? DateTime.tryParse(json['jam_keluar']) : null,
      alamatMasuk: json['alamat_masuk'] ?? '',
      alamatKeluar: json['alamat_keluar'] ?? '',
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal.toIso8601String(),
        'jam_masuk': jamMasuk?.toIso8601String(),
        'jam_keluar': jamKeluar?.toIso8601String(),
        'alamat_masuk': alamatMasuk,
        'alamat_keluar': alamatKeluar,
        'status': status,
        'alasan_izin': alasanIzin,
      };
}

class ApiResponse<T> {
  final String message;
  final T? data;

  ApiResponse({
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonData,
  ) {
    return ApiResponse(
      message: json['message'],
      data: json['data'] != null && fromJsonData != null
          ? fromJsonData(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data,
      };
}
