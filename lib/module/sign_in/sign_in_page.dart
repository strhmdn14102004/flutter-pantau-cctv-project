// ignore_for_file: use_build_context_synchronously, always_specify_types, deprecated_member_use

import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/api/endpoint/sign_in/sign_in_request.dart";
import "package:cctv_sasat/helper/generals.dart";
import "package:cctv_sasat/module/sign_in/sign_in_bloc.dart";
import "package:cctv_sasat/module/sign_in/sign_in_event.dart";
import "package:cctv_sasat/module/sign_in/sign_in_state.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:loader_overlay/loader_overlay.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:smooth_corner/smooth_corner.dart";

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> with WidgetsBindingObserver {
  final TextEditingController tecEmailAddress = TextEditingController();
  final TextEditingController tecPassword = TextEditingController();
  String? backgroundPath;
  final GlobalKey<FormState> formState =
      GlobalKey<FormState>(debugLabel: "formState");
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSelectedWallpaper();
  }

  Future<void> _loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundPath = prefs.getString("selected_wallpaper") ??
          "assets/image/background.png";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) async {
        if (state is SignInSubmitLoading) {
          context.loaderOverlay.show();
        } else if (state is SignInSubmitSuccess) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.go("/");
          }
        } else if (state is SignInSubmitFailed) {
          context.loaderOverlay.hide();
          BaseOverlays.error(message: state.errorMessage);
        } else if (state is SignInSubmitFinished) {
          context.loaderOverlay.hide();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.surface(),
          statusBarIconBrightness: AppColors.brightnessInverse(),
          systemNavigationBarColor: AppColors.surface(),
          systemNavigationBarIconBrightness: AppColors.brightnessInverse(),
        ),
        child: Scaffold(
          body: Stack(
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
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Image.asset(
                          "assets/image/logo.png",
                          width: 150,
                          height: 120,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          "wellcome".tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "sign_in_with_your_account".tr(),
                          style: TextStyle(color: Colors.white70, fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: formState,
                          child: Column(
                            children: [
                              visionInputField(
                                controller: tecEmailAddress,
                                label: "email".tr(),
                                icon: Icons.alternate_email,
                              ),
                              const SizedBox(height: 15),
                              visionInputField(
                                controller: tecPassword,
                                label: "password".tr(),
                                icon: Icons.lock,
                                obscureText: obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => obscurePassword = !obscurePassword,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        visionOSButton(
                          label: "sign_in".tr(),
                          onPressed: () {
                            if (formState.currentState?.validate() ?? false) {
                              context.read<SignInBloc>().add(
                                    SignInSubmit(
                                      signInRequest: SignInRequest(
                                        username: tecEmailAddress.text,
                                        password: tecPassword.text,
                                      ),
                                    ),
                                  );
                            }
                          },
                        ),
                        SizedBox(
                          height: Dimensions.size25,
                        ),
                        languageToggle(),
                        SizedBox(
                          height: Dimensions.size25,
                        ),
                        InkWell(
                          onTap: () {
                            context.push("/sign-up");
                          },
                          child: Text(
                            "Tidak Memiliki Akun? Daftar Disini",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Dimensions.text14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget visionInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: suffixIcon,
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget visionOSButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget languageToggle() {
    return Align(
      alignment: Alignment.center,
      child: SegmentedButton<Language>(
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            smoothness: 1,
          ),
          visualDensity: VisualDensity.compact,
          selectedBackgroundColor: AppColors.primaryContainer(),
          selectedForegroundColor: AppColors.onPrimaryContainer(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        segments: const [
          ButtonSegment(value: Language.BAHASA, label: Text("ID")),
          ButtonSegment(value: Language.ENGLISH, label: Text("EN")),
        ],
        selected: {Language.valueOf("locale".tr())},
        onSelectionChanged: (selected) {
          Generals.changeLanguage(locale: selected.first.locale);
          setState(() {});
        },
      ),
    );
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  void dispose() {
    tecEmailAddress.dispose();
    tecPassword.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
