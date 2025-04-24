// ignore_for_file: use_build_context_synchronously, always_specify_types, deprecated_member_use

import "dart:ui";

import "package:base/base.dart";
import "package:cctv_sasat/module/root/root_bloc.dart";
import "package:cctv_sasat/module/root/root_state.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class RootPage extends StatefulWidget {
  final StatefulNavigationShell statefulNavigationShell;

  const RootPage({
    required this.statefulNavigationShell,
    super.key,
  });

  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RootBloc, RootState>(
      listener: (context, state) async {},
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: AppColors.surfaceContainerLowest(),
          systemNavigationBarIconBrightness: AppColors.brightnessInverse(),
        ),
        child: Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest(),
          body: Stack(
            children: [
              widget.statefulNavigationShell,
              Align(
                alignment: Alignment.bottomCenter,
                child: bottomNavigationBar(),
              ),
            ],
          ),
        ),
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
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  Widget bottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Navigation Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    navItem(
                        icon: Icons.linked_camera_rounded,
                        index: 0,
                        label: "Cctv",),
                    SizedBox(width: 50), // Space for middle button
                    navItem(
                      icon: Icons.account_circle,
                      index: 1,
                      label: "Account",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isSelected =
        widget.statefulNavigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () {
        widget.statefulNavigationShell.goBranch(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Icon(
                icon,
                size: isSelected ? 35 : 28,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
