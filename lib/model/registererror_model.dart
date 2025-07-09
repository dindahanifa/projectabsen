// To parse this JSON data, do:
// final registerErrorResponse = registerErrorResponseFromJson(jsonString);

import 'dart:convert';

RegisterErrorResponse registerErrorResponseFromJson(String str) =>
    RegisterErrorResponse.fromJson(json.decode(str));

String registerErrorResponseToJson(RegisterErrorResponse data) =>
    json.encode(data.toJson());

class RegisterErrorResponse {
  String? message;
  RegisterErrors? errors;

  RegisterErrorResponse({
    this.message,
    this.errors,
  });

  factory RegisterErrorResponse.fromJson(Map<String, dynamic> json) =>
      RegisterErrorResponse(
        message: json["message"],
        errors: json["errors"] == null
            ? null
            : RegisterErrors.fromJson(json["errors"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "errors": errors?.toJson(),
      };
}

class RegisterErrors {
  List<String>? name;
  List<String>? email;
  List<String>? password;
  List<String>? jenisKelamin;
  List<String>? batchId;
  List<String>? trainingId;

  RegisterErrors({
    this.name,
    this.email,
    this.password,
    this.jenisKelamin,
    this.batchId,
    this.trainingId,
  });

  factory RegisterErrors.fromJson(Map<String, dynamic> json) => RegisterErrors(
        name: List<String>.from(json["name"] ?? []),
        email: List<String>.from(json["email"] ?? []),
        password: List<String>.from(json["password"] ?? []),
        jenisKelamin: List<String>.from(json["jenis_kelamin"] ?? []),
        batchId: List<String>.from(json["batch_id"] ?? []),
        trainingId: List<String>.from(json["training_id"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "name": name ?? [],
        "email": email ?? [],
        "password": password ?? [],
        "jenis_kelamin": jenisKelamin ?? [],
        "batch_id": batchId ?? [],
        "training_id": trainingId ?? [],
      };
}
