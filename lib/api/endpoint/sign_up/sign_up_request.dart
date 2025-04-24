class SignUpRequest {
  String username;
  String email;
  String password;
  String name;

  SignUpRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.name,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) => SignUpRequest(
        username: json["username"],
        email: json["email"],
        password: json["password"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "password": password,
        "name": name,
      };
}
