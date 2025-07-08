// To parse this JSON data, do
//
//     final UserResponse = registerResponseFromJson(jsonString);

import 'dart:convert';

class UserResponse {
  final String? message;
  final Data? data;

  UserResponse({this.message, this.data});

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

  Data({this.token, this.user});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user": user?.toJson(),
  };
}

class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String jenisKelamin;
  final int batchId;
  final int trainingId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    required this.batchId,
    required this.trainingId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        jenisKelamin: json["jenisKelamin"],
        batchId: json["batch_id"],
        trainingId: json["training_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "jenisKelamin": jenisKelamin,
        "batch_id": batchId,
        "training_id": trainingId,
      };
}
