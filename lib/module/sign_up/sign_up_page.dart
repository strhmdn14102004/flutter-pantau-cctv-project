// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/module/sign_up/sign_up_bloc.dart";
import "package:cctv_sasat/module/sign_up/sign_up_event.dart";
import "package:cctv_sasat/module/sign_up/sign_up_state.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:smooth_corner/smooth_corner.dart";

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecPassword = TextEditingController();
  final TextEditingController name = TextEditingController();

  bool obscurePassword = true;
  String? backgroundPath;
  File? profileImage;

  bool headerVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedWallpaper();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        headerVisible = true;
      });
    });
  }

  Future<void> _loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundPath = prefs.getString("selected_wallpaper") ??
          "assets/image/background.png";
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSubmitSuccess) {
          BaseOverlays.success(message: state.message);
        } else if (state is SignUpSubmitError) {
          BaseOverlays.error(message: state.error);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    AnimatedOpacity(
                      opacity: headerVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: _visionHeader(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : const AssetImage("assets/image/logo.png")
                                as ImageProvider,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "tap_to_upload_photo".tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            name,
                            "name".tr(),
                            Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            tecEmail,
                            "email".tr(),
                            Icons.alternate_email,
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            tecPassword,
                            "password".tr(),
                            Icons.lock,
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
                          const SizedBox(height: 30),
                          _buildVisionButton(
                            label: "sign_up".tr(),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<SignUpBloc>().add(
                                      SignUpSubmit(
                                        email: tecEmail.text,
                                        password: tecPassword.text,
                                        name: name.text,
                                      ),
                                    );
                              }
                            },
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
      ),
    );
  }

  Widget _visionHeader() {
    return SmoothContainer(
      borderRadius: BorderRadius.circular(28),
      color: Colors.white.withOpacity(0.15),
      smoothness: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.turn_left_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Sign Up",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
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
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
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
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionButton({
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
}
