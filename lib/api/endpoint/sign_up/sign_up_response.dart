class SignUpResponse {
  Data data;
  bool success;

  SignUpResponse({
    required this.data,
    required this.success,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
        data: Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
      };
}

class Data {
  String message;

  Data({
    required this.message,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
