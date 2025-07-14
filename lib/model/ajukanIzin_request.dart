class AjukanIzinRequest {
  final String date;
  final String alasanIzin;

  AjukanIzinRequest({
    required this.date,
    required this.alasanIzin,
  });

  factory AjukanIzinRequest.fromJson(Map<String, dynamic> json) {
    return AjukanIzinRequest(
      date: json['date'] as String,
      alasanIzin: json['alasan_izin'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'alasan_izin': alasanIzin,
    };
  }
}