
class SignInResponse {
    Data data;
    bool success;

    SignInResponse({
        required this.data,
        required this.success,
    });

    factory SignInResponse.fromJson(Map<String, dynamic> json) => SignInResponse(
        data: Data.fromJson(json["data"]),
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
    };
}

class Data {
    String token;
    User user;

    Data({
        required this.token,
        required this.user,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    int id;
    String username;
    String email;
    String name;
    dynamic photoUrl;
    String role;

    User({
        required this.id,
        required this.username,
        required this.email,
        required this.name,
        required this.photoUrl,
        required this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        name: json["name"],
        photoUrl: json["photoUrl"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "name": name,
        "photoUrl": photoUrl,
        "role": role,
    };
}
