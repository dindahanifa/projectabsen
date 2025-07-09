// Untuk parsing JSON data:
// final userProfile = userProfileFromJson(jsonString);

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
  final String? profilePhoto;
  final String? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        profilePhoto: json["profile_photo"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "profile_photo": profilePhoto,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
