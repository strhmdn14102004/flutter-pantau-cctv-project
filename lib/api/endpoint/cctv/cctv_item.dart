class CctvItem {
  int id;
  Location location;
  String name;
  String? thumbnailUrl;
  String sourceUrl;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  CctvItem({
    required this.id,
    required this.location,
    required this.name,
    required this.thumbnailUrl,
    required this.sourceUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CctvItem.fromJson(Map<String, dynamic> json) => CctvItem(
        id: json["id"],
        location: Location.fromJson(json["location"]),
        name: json["name"],
        thumbnailUrl: json["thumbnailUrl"],
        sourceUrl: json["sourceUrl"],
        isActive: json["isActive"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "location": location.toJson(),
        "name": name,
        "thumbnailUrl": thumbnailUrl,
        "sourceUrl": sourceUrl,
        "isActive": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Location {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  Location({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
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
