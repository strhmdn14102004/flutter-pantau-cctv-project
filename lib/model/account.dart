class Account {
  String? token;

  Account parse(Map<String, dynamic> json) {
    token = json["token"];
    return this;
  }
}
