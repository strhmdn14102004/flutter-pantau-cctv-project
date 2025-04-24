// ignore_for_file: deprecated_member_use

import "dart:convert";
import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/constant/preference_key.dart";
import "package:cctv_sasat/helper/formats.dart";
import "package:cctv_sasat/helper/generals.dart";
import "package:cctv_sasat/helper/preferences.dart";
import "package:cctv_sasat/main_bloc.dart";
import "package:cctv_sasat/main_event.dart";
import "package:cctv_sasat/module/account/account_bloc.dart";
import "package:cctv_sasat/module/account/account_state.dart";
import "package:cctv_sasat/module/account/change_wallpaper.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:smooth_corner/smooth_corner.dart";

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  Map<String, dynamic>? user;
  String? backgroundPath;

  @override
  void initState() {
    super.initState();
    loadUserData();
    WidgetsBinding.instance.addObserver(this);
    _loadSelectedWallpaper();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSelectedWallpaper();
  }

  Future<void> _loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundPath = prefs.getString("selected_wallpaper") ??
          "assets/image/background.png";
    });
  }

  Future<void> loadUserData() async {
    user = await getUserData();
    setState(() {});
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user_data");

    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return {"fullName": "User"};
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {},
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (backgroundPath == null)
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: backgroundPath!.startsWith("assets/")
                          ? AssetImage(backgroundPath!) as ImageProvider
                          : FileImage(File(backgroundPath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _visionHeader(),
                    _visionBody(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visionHeader() {
    return user == null
        ? BaseWidgets.shimmer()
        : Padding(
            padding: const EdgeInsets.all(20),
            child: SmoothContainer(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.15),
              smoothness: 1,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formats.spell("about_account".tr()),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          Formats.spell(
                            user!["name"].toString().toUpperCase(),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Text(
                          Formats.initials(user!["name"]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget _visionBody() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          _glassCard(
            icon: Icons.wallpaper_rounded,
            title: "Ubah Wallpaper",
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WallpaperSettingsPage(),
                ),
              );
              _loadSelectedWallpaper();
            },
          ),
          const SizedBox(height: 12),
       
          _glassCard(
            icon: Icons.translate,
            title: "change_language".tr(),
            trailing: Text(
              Language.valueOf("locale".tr()) == Language.ENGLISH
                  ? "English"
                  : "Bahasa",
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              List<SpinnerItem> spinnerItems = [
                SpinnerItem(
                  identity: Language.BAHASA,
                  description: "Bahasa",
                  selected: Language.valueOf("locale".tr()) == Language.BAHASA,
                ),
                SpinnerItem(
                  identity: Language.ENGLISH,
                  description: "English",
                  selected: Language.valueOf("locale".tr()) == Language.ENGLISH,
                ),
              ];

              await BaseSheets.spinner(
                title: "change_language".tr(),
                context: context,
                spinnerItems: spinnerItems,
                onSelected: (selectedItem) async {
                  Generals.changeLanguage(locale: selectedItem.identity.locale);
                  setState(() {});
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _glassCard(
            icon: AppColors.darkMode() ? Icons.dark_mode : Icons.light_mode,
            title: "theme_mode".tr(),
            trailing: Text(
              translateTheme(),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              int value = Preferences.getInt(PreferenceKey.THEME_MODE) ?? 0;
              List<SpinnerItem> spinnerItems = [
                SpinnerItem(
                  identity: 0,
                  description: "system".tr(),
                  selected: value == 0,
                ),
                SpinnerItem(
                  identity: 1,
                  description: "light".tr(),
                  selected: value == 1,
                ),
                SpinnerItem(
                  identity: 2,
                  description: "dark".tr(),
                  selected: value == 2,
                ),
              ];

              BaseSheets.spinner(
                title: "theme_mode".tr(),
                context: context,
                spinnerItems: spinnerItems,
                onSelected: (selectedItem) {
                  context
                      .read<MainBloc>()
                      .add(MainThemeChanged(value: selectedItem.identity));
                },
              );
            },
          ),
          const SizedBox(height: 20),
          _glassCard(
            icon: Icons.security,
            title: "version".tr(),
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.version,
                    style: const TextStyle(color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 12),
          _glassCard(
            icon: Icons.logout,
            title: "sign_out".tr(),
            color: Colors.red.withOpacity(0.2),
            textColor: Colors.redAccent,
            onTap: () {
              BaseDialogs.confirmation(
                title: "sign_out".tr(),
                message: "are_you_sure_want_to_sign_out".tr(),
                positiveCallback: () async {
                  await Generals.signOut(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glassCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color color = const Color(0x33FFFFFF),
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SmoothContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        smoothness: 1,
        color: color,
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: textColor)),
            ),
            if (trailing != null) trailing,
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  String translateTheme() {
    int value = Preferences.getInt(PreferenceKey.THEME_MODE) ?? 0;
    if (value == 1) {
      return "light".tr();
    }
    if (value == 2) {
      return "dark".tr();
    }
    return "system".tr();
  }
}
