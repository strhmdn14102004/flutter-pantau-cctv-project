// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/main.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class WallpaperSettingsPage extends StatefulWidget {
  const WallpaperSettingsPage({super.key});

  @override
  State<WallpaperSettingsPage> createState() => _WallpaperSettingsPageState();
}

class _WallpaperSettingsPageState extends State<WallpaperSettingsPage> {
  final List<String> _defaultWallpapers = [
    "assets/image/background.png",
    "assets/image/bacgkround.png",
  ];
  String? _selectedWallpaperPath;

  @override
  void initState() {
    super.initState();
    _selectedWallpaperPath = wallpaperNotifier.value;
  }

  Future<void> _setWallpaper(String path) async {
    await wallpaperNotifier.setWallpaper(path);
    setState(() => _selectedWallpaperPath = path);
  }

  Future<void> _pickCustomWallpaper() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _setWallpaper(picked.path);
    }
  }

  Widget _buildWallpaperCard(String path, {bool isAsset = true}) {
    final isSelected = _selectedWallpaperPath == path;
    final size = MediaQuery.of(context).size.width * 0.4;

    return GestureDetector(
      onTap: () => _setWallpaper(path),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(Dimensions.size10),
        width: size,
        height: size * 1.77,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.size20),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.5 : 0.3),
              blurRadius: Dimensions.size10,
              spreadRadius: Dimensions.size2,
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: Dimensions.size15,
                spreadRadius: Dimensions.size2,
              ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.size20),
              child: isAsset
                  ? Image.asset(path, fit: BoxFit.cover)
                  : Image.file(File(path), fit: BoxFit.cover),
            ),
            if (isSelected)
              Positioned(
                top: Dimensions.size10,
                right: Dimensions.size10,
                child: Container(
                  padding: EdgeInsets.all(Dimensions.size5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: Dimensions.size20,
                  ),
                ),
              ),
          ],
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _selectedWallpaperPath == null
                    ? AssetImage(_defaultWallpapers.first)
                    : _defaultWallpapers.contains(_selectedWallpaperPath!)
                        ? AssetImage(_selectedWallpaperPath!)
                        : FileImage(File(_selectedWallpaperPath!))
                            as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: Dimensions.size30,
                sigmaY: Dimensions.size30,
              ),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: EdgeInsets.only(left: Dimensions.size15),
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(Dimensions.size10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: Dimensions.size20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  title: Text(
                    "wallpaper_setting".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: Dimensions.text20,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: Dimensions.size4,
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: Dimensions.size15,
                    right: Dimensions.size20,
                    top: Dimensions.size15,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader("default_wallpaper".tr()),
                      SizedBox(height: Dimensions.size10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          physics: const BouncingScrollPhysics(),
                          children: _defaultWallpapers
                              .map((path) => _buildWallpaperCard(path))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: Dimensions.size10),
                      _buildSectionHeader("custom_wallpaper".tr()),
                      SizedBox(height: Dimensions.size15),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(Dimensions.size20),
                          onTap: _pickCustomWallpaper,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.size20,
                              horizontal: Dimensions.size20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.size20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: Dimensions.size15),
                                Text(
                                  "choose_from_gallery".tr(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: Dimensions.text14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.size15),
                      if (_selectedWallpaperPath != null &&
                          !_defaultWallpapers.contains(_selectedWallpaperPath!))
                        Column(
                          children: [
                            _buildSectionHeader(
                              "current_custom_Wallpaper".tr(),
                            ),
                            SizedBox(height: Dimensions.size10),
                            _buildWallpaperCard(
                              _selectedWallpaperPath!,
                              isAsset: false,
                            ),
                            SizedBox(height: Dimensions.size30),
                          ],
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.size10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: Dimensions.text18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
