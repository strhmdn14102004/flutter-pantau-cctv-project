// ignore_for_file: deprecated_member_use

import "dart:io";
import "dart:ui";

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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar-like header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.turn_left_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Change Wallpaper",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Default Wallpapers
                  const Text(
                    "Default Wallpapers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: defaultWallpapers
                          .map((path) => _wallpaperPreview(path))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Custom Wallpaper
                  const Text(
                    "Custom Wallpaper",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _pickCustomWallpaper,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white70),
                            SizedBox(width: 10),
                            Text(
                              "Pick from Gallery",
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
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          const Text(
                            "Current Custom Wallpaper Preview",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
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
