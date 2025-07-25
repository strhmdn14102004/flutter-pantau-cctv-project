// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import "dart:convert";
import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/constant/preference_key.dart";
import "package:cctv_sasat/helper/generals.dart";
import "package:cctv_sasat/helper/glass.dart";
import "package:cctv_sasat/helper/preferences.dart";
import "package:cctv_sasat/main.dart";
import "package:cctv_sasat/main_bloc.dart";
import "package:cctv_sasat/main_event.dart";
import "package:cctv_sasat/module/account/account_bloc.dart";
import "package:cctv_sasat/module/account/account_state.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUserData();
    WidgetsBinding.instance.addObserver(this);
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: wallpaperNotifier,
      builder: (context, wallpaperPath, _) {
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
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: wallpaperPath == null
                            ? AssetImage(
                                Theme.of(context).brightness == Brightness.dark
                                    ? "assets/image/background.png"
                                    : "assets/image/background.png",
                              )
                            : wallpaperPath.startsWith("assets/")
                                ? AssetImage(wallpaperPath) as ImageProvider
                                : FileImage(File(wallpaperPath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: Dimensions.size15,
                      sigmaY: Dimensions.size15,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                  SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Dimensions.size20,
                              right: Dimensions.size20,
                              top: Dimensions.size20,
                              bottom: Dimensions.size10,
                            ),
                            child: _buildProfileHeader(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Dimensions.size20,
                              right: Dimensions.size20,
                              top: Dimensions.size5,
                              bottom: Dimensions.size5,
                            ),
                            child: _buildAccountStatusBanner(),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.size20,
                            vertical: Dimensions.size1,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildSettingsSectionTitle(
                                "account_setting".tr(),
                              ),
                              _buildSettingsCard(
                                icon: Icons.wallpaper_outlined,
                                title: "change_wallpaper".tr(),
                                onTap: () => context.push("/change-wallpaper"),
                              ),
                              if (user?["accountStatus"] == "free")
                                _buildSettingsCard(
                                  icon: Icons.no_accounts_rounded,
                                  title: "upgrade_to_pro".tr(),
                                  onTap: () => context.push("/upgrade-account"),
                                ),
                              SizedBox(height: Dimensions.size10),
                              _buildSettingsSectionTitle("app_settings".tr()),
                              _buildSettingsCard(
                                icon: Icons.language_outlined,
                                title: "language".tr(),
                                trailing: Text(
                                  Language.valueOf("locale".tr()) ==
                                          Language.ENGLISH
                                      ? "English"
                                      : "Bahasa",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Dimensions.text14,
                                  ),
                                ),
                                onTap: () => _showLanguageDialog(),
                              ),
                              _buildSettingsCard(
                                icon: AppColors.darkMode()
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                title: "theme".tr(),
                                trailing: Text(
                                  translateTheme(),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Dimensions.text14,
                                  ),
                                ),
                                onTap: () => _showThemeDialog(),
                              ),
                              _buildSettingsCard(
                                icon: Icons.info_outline,
                                title: "app_version".tr(),
                                trailing: FutureBuilder<PackageInfo>(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data!.version,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Dimensions.text14,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              SizedBox(height: Dimensions.size20),
                              _buildSignOutButton(),
                              SizedBox(height: Dimensions.size80),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountStatusBanner() {
    if (user == null || user!["accountStatus"] == null) {
      return const SizedBox.shrink();
    }

    final isFreeAccount = user!["accountStatus"] == "free";
    final isPaidAccount = user!["accountStatus"] == "paid";

    if (!isFreeAccount && !isPaidAccount) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(Dimensions.size15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.size15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFreeAccount
              ? [
                  Colors.orange.withOpacity(0.3),
                  Colors.red.withOpacity(0.3),
                ]
              : [
                  Colors.green.withOpacity(0.3),
                  Colors.teal.withOpacity(0.3),
                ],
        ),
        border: Border.all(
          color: isFreeAccount
              ? Colors.orange.withOpacity(0.5)
              : Colors.green.withOpacity(0.5),
          width: Dimensions.size1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFreeAccount ? Icons.info_outline : Icons.verified_user,
            color:
                isFreeAccount ? Colors.orange.shade200 : Colors.green.shade200,
            size: Dimensions.size20,
          ),
          SizedBox(width: Dimensions.size10),
          Expanded(
            child: Text(
              isFreeAccount
                  ? "kamu_sedang_menggunakan_akun-gratis.upgrade_ke_versi_member_untuk_dapatkan_data_cctv_secara_menyeluruh"
                      .tr()
                  : "kamu_adalah_member_selamat_menikmati_akses_cctv_secara_menyeluruh"
                      .tr(),
              style: TextStyle(
                color: isFreeAccount
                    ? Colors.orange.shade200
                    : Colors.green.shade200,
                fontSize: Dimensions.text14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return user == null
        ? BaseWidgets.shimmer()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.size35),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: Dimensions.size1,
              ),
            ),
            padding: EdgeInsets.all(Dimensions.size20),
            child: Row(
              children: [
                Container(
                  width: Dimensions.size60,
                  height: Dimensions.size70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary(),
                        AppColors.onPrimary(),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: Dimensions.size10,
                        spreadRadius: Dimensions.size2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user!["name"].toString()),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: Dimensions.text24,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.size15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "your_account".tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: Dimensions.text14,
                        ),
                      ),
                      SizedBox(height: Dimensions.size3),
                      Text(
                        user!["name"].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.text18,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Dimensions.size3),
                      Text(
                        user!["email"].toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: Dimensions.text14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) {
      return "";
    }
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }

  Widget _buildSettingsSectionTitle(String title) {
    return Padding(
      padding:
          EdgeInsets.only(top: Dimensions.size15, bottom: Dimensions.size10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: Dimensions.text14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.size10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.size15),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.size15),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.size20,
              vertical: Dimensions.size15,
            ),
            child: Row(
              children: [
                Container(
                  width: Dimensions.size35,
                  height: Dimensions.size35,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: Dimensions.size20,
                  ),
                ),
                SizedBox(width: Dimensions.size15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.text16,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                SizedBox(width: Dimensions.size10),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.size15),
        onTap: () {
          showGlassDialog(
            context: context,
            title: "sign_out".tr(),
            message: "are_you_sure_want_to_sign_out".tr(),
            positiveText: "sign_out".tr(),
            negativeText: "cancel".tr(),
            positiveCallback: () async {
              await Generals.signOut(context);
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.size15),
            color: Colors.red.withOpacity(0.2),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.size20,
            vertical: Dimensions.size15,
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.size35,
                height: Dimensions.size35,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: Dimensions.size20,
                ),
              ),
              SizedBox(width: Dimensions.size15),
              Expanded(
                child: Text(
                  "sign_out".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.text16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
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
  }

  void _showThemeDialog() {
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
