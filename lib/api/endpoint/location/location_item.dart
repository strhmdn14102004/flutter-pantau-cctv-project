class LocationItem {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  LocationItem({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) => LocationItem(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
