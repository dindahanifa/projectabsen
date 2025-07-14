class AbsenCoRequest {
  final String attendanceDate;
  final String checkOut;
  final String checkOutLat;
  final String checkOutLng;
  final String checkOutLocation;
  final String checkOutAddress;

  AbsenCoRequest({
    required this.attendanceDate,
    required this.checkOut,
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkOutLocation,
    required this.checkOutAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'attendance_date': attendanceDate,
      'check_out': checkOut,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_out_location': checkOutLocation,
      'check_out_address': checkOutAddress,
    };
  }
}