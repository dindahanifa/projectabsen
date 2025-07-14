
class AbsenToday {
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String status;
  final String? alasanIzin;

  AbsenToday({
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenToday.fromJson(Map<String, dynamic> json) {
    return AbsenToday(
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInAddress: json['check_in_address'],
      checkOutAddress: json['check_out_address'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_date': attendanceDate,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'check_in_address': checkInAddress,
      'check_out_address': checkOutAddress,
      'status': status,
      'alasan_izin': alasanIzin,
    };
  }
}