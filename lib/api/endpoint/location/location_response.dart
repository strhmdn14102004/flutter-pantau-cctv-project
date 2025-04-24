import "package:cctv_sasat/api/endpoint/location/location_item.dart";

class LocationResponse {
  List<LocationItem> data;
  bool success;

  LocationResponse({
    required this.data,
    required this.success,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      LocationResponse(
        data: List<LocationItem>.from(json["data"].map((x) => LocationItem.fromJson(x))),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "success": success,
      };
}

