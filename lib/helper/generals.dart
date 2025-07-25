import "package:cctv_sasat/api/api_manager.dart";
import "package:cctv_sasat/constant/api_url.dart";
import "package:cctv_sasat/shared.dart";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";

class Generals {
  static BuildContext? context() {
    return Get.context;
  }

  static GlobalKey<NavigatorState> navigatorState() {
    return Get.key;
  }

  // static Future<void> self() async {
  //   if (Preferences.contain(PreferenceKey.SESSION_ID)) {
  //     dio.Response response = await ApiManager.account();

  //     if (response.statusCode == 200) {
  //       Shared.ACCOUNT = Account().parse(response.data);
  //     }
  //   }
  // }

  static Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    // Panggil API logout jika token tersedia
    if (token != null) {
      try {
        final dio = await ApiManager.getDio();
        final response = await dio.post(
          ApiUrl.LOGOUT.path,
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
            },
          ),
        );

        // Handle jika logout gagal di server
        if (response.statusCode != 200) {
          throw Exception("Logout failed with status ${response.statusCode}");
        }
      } catch (e) {
        // Tangani error jika logout gagal
        if (kDebugMode) {
          print("Error during logout: $e");
        }
        // Tetap lanjutkan bersihkan data lokal meskipun API gagal
      }
    }

    // Bersihkan data lokal
    await prefs.remove("SESSION_ID");
    await prefs.remove("auth_token");
    await prefs.remove("user_data");

    Shared.ACCOUNT = null;

    if (context.mounted) {
      context.go("/sign-in");
    }
  }

  static void changeLanguage({
    required String locale,
  }) async {
    if (context() != null) {
      context()!.setLocale(Locale.fromSubtags(languageCode: locale));

      Locale newLocale = Locale(locale);

      await context()!.setLocale(newLocale);

      Get.updateLocale(newLocale);
    }
  }
}
