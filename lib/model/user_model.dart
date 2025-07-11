// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

UserResponse userResponseFromJson(String str) => UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  final String? message;
  final Data? data;

  UserResponse({
    this.message,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final String? token;
  final User? user;
  final dynamic profilePhotoUrl;

  Data({
    this.token,
    this.user,
    this.profilePhotoUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        profilePhotoUrl: json["profile_photo_url"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
        "profile_photo_url": profilePhotoUrl,
      };
}

class User {
  final String? name;
  final String? email;
  final int? batchId;
  final int? trainingId;
  final String? jenisKelamin;
  final dynamic profilePhoto;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;
  final Batch? batch;
  final Training? training;

  User({
    this.name,
    this.email,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        email: json["email"],
        batchId: json["batch_id"] == null ? null : int.tryParse(json["batch_id"].toString()),
        trainingId: json["training_id"] == null ? null : int.tryParse(json["training_id"].toString()),
        jenisKelamin: json["jenis_kelamin"],
        profilePhoto: json["profile_photo"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
        batch: json["batch"] == null ? null : Batch.fromJson(json["batch"]),
        training: json["training"] == null ? null : Training.fromJson(json["training"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "batch_id": batchId,
        "training_id": trainingId,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
        "batch": batch?.toJson(),
        "training": training?.toJson(),
      };
}

class Batch {
  final int? id;
  final String? batchKe;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Batch({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json["id"],
        batchKe: json["batch_ke"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": startDate != null
            ? "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
            : null,
        "end_date": endDate != null
            ? "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
            : null,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Training {
  final int? id;
  final String? title;
  final dynamic description;
  final dynamic participantCount;
  final dynamic standard;
  final dynamic duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Training({
    this.id,
    this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        participantCount: json["participant_count"],
        standard: json["standard"],
        duration: json["duration"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "participant_count": participantCount,
        "standard": standard,
        "duration": duration,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
