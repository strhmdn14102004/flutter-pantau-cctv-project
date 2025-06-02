
class SignInRequest {
    String username;
    String password;

      SignInRequest({
        required this.username,
        required this.password,
    });

    factory SignInRequest.fromJson(Map<String, dynamic> json) => SignInRequest(
        username: json["username"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
    };
}
