class LupaPasswordRequest {
  final String email;

  LupaPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

class LupaPasswordResponse {
  final String message;

  LupaPasswordResponse({required this.message});

  factory LupaPasswordResponse.fromJson(Map<String, dynamic> json) {
    return LupaPasswordResponse(
      message: json['message'] as String,
    );
  }
}