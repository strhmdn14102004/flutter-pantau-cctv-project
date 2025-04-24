class LocationRequest {
  String name;

  LocationRequest({
    required this.name,
  });

  factory LocationRequest.fromJson(Map<String, dynamic> json) =>
      LocationRequest(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
