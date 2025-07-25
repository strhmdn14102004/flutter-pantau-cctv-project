// ignore_for_file: unnecessary_string_interpolations, non_constant_identifier_names

import "dart:convert";

import "package:base/base.dart";
import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";
import "package:cctv_sasat/api/endpoint/location/location_item.dart";
import "package:cctv_sasat/api/endpoint/sign_in/sign_in_request.dart";
import "package:cctv_sasat/api/endpoint/sign_up/sign_up_request.dart";
import "package:cctv_sasat/api/interceptor/authorization_interceptor.dart";
import "package:cctv_sasat/constant/api_url.dart";
import "package:cctv_sasat/helper/formats.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

class ApiManager {
  static bool PRIMARY = true;

  static Future<Dio> getDio() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: PRIMARY ? MAIN_BASE : SECONDARY_BASE,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        contentType: Headers.jsonContentType,
        receiveDataWhenStatusError: false,
        validateStatus: (status) => status != null,
        responseDecoder: (responseBytes, options, responseBody) {
          String value = utf8.decode(responseBytes, allowMalformed: true);

          if (responseBody.statusCode >= 300) {
            try {
              return jsonDecode(value);
            } catch (ex) {
              return value;
            }
          } else {
            return value;
          }
        },
      ),
    );

    dio.interceptors.add(BaseEncodingInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        request: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
    dio.interceptors.add(AuthorizationInterceptor());

    return dio;
  }

  static Future<Uint8List> download({
    required String url,
  }) async {
    Response response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    return response.data;
  }

  static Future<Response> signIn({
    required SignInRequest signInRequest,
  }) async {
    Dio dio = await getDio();

    Response response = await dio.post(
      ApiUrl.SIGN_IN.path,
      data: Formats.convert(signInRequest.toJson()),
    );

    return response;
  }

  static Future<Response> signUp({
    required SignUpRequest signUpRequest,
  }) async {
    Dio dio = await getDio();

    Response response = await dio.post(
      ApiUrl.SIGN_UP.path,
      data: Formats.convert(signUpRequest.toJson()),
    );

    return response;
  }

  static Future<List<CctvItem>> getAllCctvs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      Dio dio = await getDio();
      final response = await dio.get(
        ApiUrl.CCTV.path,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data["data"];
        return data.map((json) => CctvItem.fromJson(json)).toList();
      } else {
        throw Exception("Gagal memuat data CCTV");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  static Future<List<LocationItem>> getAllLocations() async {
    try {
      Dio dio = await getDio();
      final response = await dio.get(ApiUrl.LOCATION.path);
      if (response.statusCode == 200) {
        final List data = response.data["data"];
        return data.map((json) => LocationItem.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
