// ================== MODEL ABSEN ==================
class AbsenModel {
  final int? id;
  final int? userId;
  final String? status;
  final String? alasanIzin;

  final double? checkInLat;
  final double? checkInLng;
  final String? checkInAddress;
  final DateTime? checkIn;

  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkOutAddress;
  final DateTime? checkOut;

  final DateTime? attendanceDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AbsenModel({
    this.id,
    this.userId,
    this.status,
    this.alasanIzin,
    this.checkInLat,
    this.checkInLng,
    this.checkInAddress,
    this.checkIn,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutAddress,
    this.checkOut,
    this.attendanceDate,
    this.createdAt,
    this.updatedAt,
  });

  factory AbsenModel.fromJson(Map<String, dynamic> json) {
    return AbsenModel(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkInAddress: json['check_in_address'],
      checkIn: json['check_in'] != null ? DateTime.tryParse(json['check_in']) : null,
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
      checkOutAddress: json['check_out_address'],
      checkOut: json['check_out'] != null ? DateTime.tryParse(json['check_out']) : null,
      attendanceDate: json['attendance_date'] != null ? DateTime.tryParse(json['attendance_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'alasan_izin': alasanIzin,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_in_address': checkInAddress,
      'check_in': checkIn?.toIso8601String(),
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_out_address': checkOutAddress,
      'check_out': checkOut?.toIso8601String(),
      'attendance_date': attendanceDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class AbsenResponse {
  final String message;
  final AbsenModel? data;

  AbsenResponse({required this.message, required this.data});

  factory AbsenResponse.fromJson(Map<String, dynamic> json) {
    return AbsenResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? AbsenModel.fromJson(json['data']) : null,
    );
  }
}

class ListAbsenResponse {
  final String message;
  final List<AbsenModel> data;

  ListAbsenResponse({required this.message, required this.data});

  factory ListAbsenResponse.fromJson(Map<String, dynamic> json) {
    return ListAbsenResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AbsenModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StatistikAbsen {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  StatistikAbsen({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory StatistikAbsen.fromJson(Map<String, dynamic> json) {
    return StatistikAbsen(
      totalAbsen: json['total_absen'] ?? 0,
      totalMasuk: json['total_masuk'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
      sudahAbsenHariIni: json['sudah_absen_hari_ini'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_absen': totalAbsen,
        'total_masuk': totalMasuk,
        'total_izin': totalIzin,
        'sudah_absen_hari_ini': sudahAbsenHariIni,
      };
}

class StatistikResponse {
  final String message;
  final StatistikAbsen? data;

  StatistikResponse({required this.message, required this.data});

  factory StatistikResponse.fromJson(Map<String, dynamic> json) {
    return StatistikResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? StatistikAbsen.fromJson(json['data']) : null,
    );
  }
}
