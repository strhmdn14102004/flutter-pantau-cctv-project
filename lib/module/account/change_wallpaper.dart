// ignore_for_file: deprecated_member_use

import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";

class WallpaperSettingsPage extends StatefulWidget {
  const WallpaperSettingsPage({super.key});

  @override
  State<WallpaperSettingsPage> createState() => _WallpaperSettingsPageState();
}

class _WallpaperSettingsPageState extends State<WallpaperSettingsPage> {
  List<String> defaultWallpapers = [
    "assets/image/background.png",
    "assets/image/background1.png",
    "assets/image/background2.png",
    "assets/image/background3.png",
  ];

  String? selectedWallpaperPath;

  @override
  void initState() {
    super.initState();
    _loadSelectedWallpaper();
  }

  Future<void> _loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedWallpaperPath = prefs.getString("selected_wallpaper");
    });
  }

  Future<void> _setWallpaper(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_wallpaper", path);
    setState(() => selectedWallpaperPath = path);
  }

  Future<void> _pickCustomWallpaper() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _setWallpaper(picked.path);
    }
  }

  Widget _wallpaperPreview(String path, {bool isAsset = true}) {
    final isSelected = selectedWallpaperPath == path;

    return GestureDetector(
      onTap: () => _setWallpaper(path),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.size10,
          vertical: Dimensions.size10,
        ),
        width: Dimensions.size100,
        height: Dimensions.size100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.size20),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: Dimensions.size10,
                spreadRadius: Dimensions.size1,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.size20),
          child: isAsset
              ? Image.asset(path, fit: BoxFit.cover)
              : Image.file(File(path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Blurred background layer
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  selectedWallpaperPath ?? defaultWallpapers.first,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: Dimensions.size20,
                sigmaY: Dimensions.size20,
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Dimensions.size20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar-like header
                  Container(
                    padding: EdgeInsets.all(Dimensions.size15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.size25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.turn_left_rounded,
                            color: Colors.white,
                            size: Dimensions.size35,
                          ),
                        ),
                        SizedBox(width: Dimensions.size10),
                        Text(
                          "change_wallpaper".tr(),
                          style: TextStyle(
                            fontSize: Dimensions.text18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.size30),

                  // Default Wallpapers
                  Text(
                    "default_wallpapers".tr(),
                    style: TextStyle(
                      fontSize: Dimensions.text18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Dimensions.size10),
                  SizedBox(
                    height: Dimensions.size100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: defaultWallpapers
                          .map((path) => _wallpaperPreview(path))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: Dimensions.size10),

                  // Custom Wallpaper
                  Text(
                    "custom_wallpaper".tr(),
                    style: TextStyle(
                      fontSize: Dimensions.text18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Dimensions.size10),
                  Center(
                    child: GestureDetector(
                      onTap: _pickCustomWallpaper,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.size15,
                          horizontal: Dimensions.size20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size20),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white70),
                            SizedBox(width: Dimensions.size10),
                            Text(
                              "pick_from_gallery".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Show preview if custom wallpaper selected
                  if (selectedWallpaperPath != null &&
                      !defaultWallpapers.contains(selectedWallpaperPath!))
                    Padding(
                      padding: EdgeInsets.only(top: Dimensions.size30),
                      child: Column(
                        children: [
                          Text(
                            "current_custom_wallpaper_preview".tr(),
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: Dimensions.size10),
                          _wallpaperPreview(
                            selectedWallpaperPath!,
                            isAsset: false,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
