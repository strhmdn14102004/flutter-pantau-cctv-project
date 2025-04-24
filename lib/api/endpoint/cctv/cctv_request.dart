class CctvRequest {
  int locationId;
  String name;
  String thumbnailUrl;
  String sourceUrl;

  CctvRequest({
    required this.locationId,
    required this.name,
    required this.thumbnailUrl,
    required this.sourceUrl,
  });

  factory CctvRequest.fromJson(Map<String, dynamic> json) => CctvRequest(
        locationId: json["locationId"],
        name: json["name"],
        thumbnailUrl: json["thumbnailUrl"],
        sourceUrl: json["sourceUrl"],
      );

  Map<String, dynamic> toJson() => {
        "locationId": locationId,
        "name": name,
        "thumbnailUrl": thumbnailUrl,
        "sourceUrl": sourceUrl,
      };
}
