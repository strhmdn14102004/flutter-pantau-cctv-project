  import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";

  class CctvResponse {
    List<CctvItem> data;
    bool success;

    CctvResponse({
      required this.data,
      required this.success,
    });

    factory CctvResponse.fromJson(Map<String, dynamic> json) => CctvResponse(
          data:
              List<CctvItem>.from(json["data"].map((x) => CctvItem.fromJson(x))),
          success: json["success"],
        );

    Map<String, dynamic> toJson() => {
          "data": List<dynamic>.from(data.map((x) => x.toJson())),
          "success": success,
        };
  }
