// wallpaper_notifier.dart
// ignore_for_file: depend_on_referenced_packages

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

class WallpaperNotifier extends ValueNotifier<String?> {
  static const String _key = "wallpaper_path";

  WallpaperNotifier() : super(null) {
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_key);
  }

  Future<void> setWallpaper(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
    value = path;
  }

  static final WallpaperNotifier instance = WallpaperNotifier();
}
