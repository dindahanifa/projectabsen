import 'dart:convert';

//CheckInModel

class CheckInModel {
  final double lat;
  final double lng;
  final String address;
  final String status;
  final String? alasanIzin;

  CheckInModel({
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
    this.alasanIzin,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      lat: double.parse(json['check_in_lat']),
      lng: double.parse(json['check_in_lng']),
      address: json['check_in_address'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in_lat': lat.toString(),
      'check_in_lng': lng.toString(),
      'check_in_address': address,
      'status': status,
      if (alasanIzin != null) 'alasan_izin': alasanIzin,
    };
  }
}

//CheckOutModel

class CheckOutModel {
  final double lat;
  final double lng;
  final String location;
  final String address;

  CheckOutModel({
    required this.lat,
    required this.lng,
    required this.location,
    required this.address,
  });

  factory CheckOutModel.fromJson(Map<String, dynamic> json) {
    return CheckOutModel(
      lat: double.parse(json['check_out_lat']),
      lng: double.parse(json['check_out_lng']),
      location: json['check_out_location'],
      address: json['check_out_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_out_lat': lat.toString(),
      'check_out_lng': lng.toString(),
      'check_out_location': location,
      'check_out_address': address,
    };
  }
}

class KehadiranModel {
  final CheckInModel checkIn;
  final CheckOutModel? checkOut;

  KehadiranModel({
    required this.checkIn,
    this.checkOut,
  });
}

//CheckInRespon

CheckInRespon checkInResponFromJson(String str) =>
    CheckInRespon.fromJson(json.decode(str));

String checkInResponToJson(CheckInRespon data) => json.encode(data.toJson());

class CheckInRespon {
  final String? message;

  CheckInRespon({
    this.message,
  });

  factory CheckInRespon.fromJson(Map<String, dynamic> json) => CheckInRespon(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}

//CheckOutRespon

CheckOutRespon checkOutResponFromJson(String str) =>
    CheckOutRespon.fromJson(json.decode(str));

String checkOutResponToJson(CheckOutRespon data) =>
    json.encode(data.toJson());

class CheckOutRespon {
  final String? message;

  CheckOutRespon({
    this.message,
  });

  factory CheckOutRespon.fromJson(Map<String, dynamic> json) => CheckOutRespon(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}

//StatistikModel

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
        "hadir": hadir,
        "izin": izin,
        "total": total,
      };
}