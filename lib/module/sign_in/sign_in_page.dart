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
                    filter: ImageFilter.blur(
                      sigmaX: Dimensions.size20,
                      sigmaY: Dimensions.size20,
                    ),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.size20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: Dimensions.size80),
                        Image.asset(
                          "assets/image/logo.png",
                          width: 150,
                          height: 120,
                        ),
                        SizedBox(height: Dimensions.size50),
                        Text(
                          "wellcome".tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.text24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "sign_in_with_your_account".tr(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Dimensions.text20,
                          ),
                        ),
                        SizedBox(height: Dimensions.size20),
                        Form(
                          key: formState,
                          child: Column(
                            children: [
                              visionInputField(
                                controller: tecEmailAddress,
                                label: "email".tr(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "email_is_required".tr();
                                  }
                                  return null;
                                },
                                icon: Icons.alternate_email,
                              ),
                              SizedBox(height: Dimensions.size15),
                              visionInputField(
                                controller: tecPassword,
                                label: "password".tr(),
                                icon: Icons.lock,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "password_is_required".tr();
                                  }
                                  return null;
                                },
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
                        SizedBox(height: Dimensions.size30),
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
                            "no_have_account?register_here".tr(),
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
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.size20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Dimensions.size10,
          sigmaY: Dimensions.size10,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.size20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: suffixIcon,
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(Dimensions.size20),
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
        height: Dimensions.size50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.size20),
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
              blurRadius: Dimensions.size10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.text16,
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
            borderRadius: BorderRadius.circular(Dimensions.size10),
            smoothness: 1,
          ),
          visualDensity: VisualDensity.compact,
          selectedBackgroundColor: AppColors.primaryContainer(),
          selectedForegroundColor: AppColors.onPrimaryContainer(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            fontSize: Dimensions.text12,
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
