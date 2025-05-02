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
                padding: EdgeInsets.all(Dimensions.size20),
                child: Column(
                  children: [
                    SizedBox(height: Dimensions.size10),
                    AnimatedOpacity(
                      opacity: headerVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: _visionHeader(),
                    ),
                    SizedBox(height: Dimensions.size20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: Dimensions.size45,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : const AssetImage("assets/image/logo.png")
                                as ImageProvider,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    SizedBox(height: Dimensions.size10),
                    Text(
                      "tap_to_upload_photo".tr(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Dimensions.text12,
                      ),
                    ),
                    SizedBox(height: Dimensions.size30),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            name,
                            "name".tr(),
                            Icons.person,
                          ),
                          SizedBox(height: Dimensions.size15),
                          _buildInputField(
                            tecEmail,
                            "email".tr(),
                            Icons.alternate_email,
                          ),
                          SizedBox(height: Dimensions.size15),
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
                          SizedBox(height: Dimensions.size30),
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
      borderRadius: BorderRadius.circular(Dimensions.size30),
      color: Colors.white.withOpacity(0.15),
      smoothness: Dimensions.size1,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.size15,
        vertical: Dimensions.size15,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.turn_left_rounded,
              color: Colors.white,
              size: Dimensions.size30,
            ),
          ),
          SizedBox(width: Dimensions.size15),
          Text(
            "sign_up".tr(),
            style: TextStyle(
              fontSize: Dimensions.text20,
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
        filter: ImageFilter.blur(
          sigmaX: Dimensions.size20,
          sigmaY: Dimensions.size20,
        ),
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: suffixIcon,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(Dimensions.size20),
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
}
