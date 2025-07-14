class AjukanIzinResponse {
  final String message;
  final IzinData data;

  AjukanIzinResponse({required this.message, required this.data});

  factory AjukanIzinResponse.fromJson(Map<String, dynamic> json) {
    return AjukanIzinResponse(
      message: json['message'],
      data: IzinData.fromJson(json['data']),
    );
  }
}

class IzinData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkInLat;
  final String? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;
  final String status;
  final String alasanIzin;

  IzinData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinData.fromJson(Map<String, dynamic> json) {
    return IzinData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkInLat: json['check_in_lat'],
      checkInLng: json['check_in_lng'],
      checkInLocation: json['check_in_location'],
      checkInAddress: json['check_in_address'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }
}