import 'dart:convert';

UserProfileResponse userProfileFromJson(String str) =>
    UserProfileResponse.fromJson(json.decode(str));

String userProfileToJson(UserProfileResponse data) =>
    json.encode(data.toJson());

class UserProfileResponse {
  final String message;
  final UserProfile data;

  UserProfileResponse({
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        message: json["message"],
        data: UserProfile.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
      };
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String batchKe;
  final String trainingTitle;
  final Batch batch;
  final Training training;
  final String jenisKelamin;
  final String? profilePhoto;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.batchKe,
    required this.trainingTitle,
    required this.batch,
    required this.training,
    required this.jenisKelamin,
    this.profilePhoto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        batchKe: json["batch_ke"],
        trainingTitle: json["training_title"],
        batch: Batch.fromJson(json["batch"]),
        training: Training.fromJson(json["training"]),
        jenisKelamin: json["jenis_kelamin"],
        profilePhoto: json["profile_photo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "batch_ke": batchKe,
        "training_title": trainingTitle,
        "batch": batch.toJson(),
        "training": training.toJson(),
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
      };
}

class Batch {
  final int id;
  final String batchKe;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json["id"],
        batchKe: json["batch_ke"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Training {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final int? duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        participantCount: json["participant_count"],
        standard: json["standard"],
        duration: json["duration"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "participant_count": participantCount,
        "standard": standard,
        "duration": duration,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
