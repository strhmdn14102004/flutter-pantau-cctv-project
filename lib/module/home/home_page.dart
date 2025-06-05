// ignore_for_file: deprecated_member_use

import "dart:convert";
import "dart:io";
import "dart:ui";

import "package:base/base.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";
import "package:cctv_sasat/helper/formats.dart";
import "package:cctv_sasat/module/home/home_bloc.dart";
import "package:cctv_sasat/module/home/home_event.dart";
import "package:cctv_sasat/module/home/home_state.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lottie/lottie.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:webview_flutter/webview_flutter.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;
  bool loading = false;
  final bool isIOS = Platform.isIOS;
  String? backgroundPath;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _loadSelectedWallpaper();
    // Trigger initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadCctvData());
      context.read<HomeBloc>().add(LoadLocations());
    });
  }

  Future<void> _loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundPath = prefs.getString("selected_wallpaper") ??
          "assets/image/background.png";
    });
  }

  void loadUserData() async {
    user = await getUserData();
    setState(() {});
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user_data");

    final userData =
        userJson != null ? jsonDecode(userJson) : {"name": "User", "email": ""};

    return {
      ...userData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is CctvDataLoading) {
          setState(() => loading = true);
        } else if (state is CctvDataLoaded || state is CctvDataError) {
          setState(() => loading = false);
        }
      },
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
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.size15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: Dimensions.size15),
                      Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          SizedBox(width: Dimensions.size10),
                          _buildFilterButton(),
                        ],
                      ),
                      SizedBox(height: Dimensions.size20),
                      _buildLocationFilter(),
                      SizedBox(height: Dimensions.size20),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildLocationFilter() {
  return BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
      if (state is! CctvDataLoaded) {
        return const SizedBox.shrink();
      }

      final locations = state.locations;
      final selectedId = state.selectedLocationId;
      if (locations.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: Dimensions.size45,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: locations.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: Dimensions.size5),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.size20),
                  color: selectedId == null 
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.15),
                  border: selectedId == null
                      ? Border.all(color: Colors.white.withOpacity(0.5))
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimensions.size20),
                    onTap: () {
                      context.read<HomeBloc>().add(FilterByLocation(null));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.size15,
                        vertical: Dimensions.size10,
                      ),
                      child: Center(
                        child: Text(
                          "All".tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final location = locations[index - 1];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.size20),
                color: selectedId == location.id
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                border: selectedId == location.id
                    ? Border.all(color: Colors.white.withOpacity(0.5))
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.size20),
                  onTap: () {
                    context.read<HomeBloc>().add(FilterByLocation(location.id));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.size15,
                      vertical: Dimensions.size10,
                    ),
                    child: Center(
                      child: Text(
                        location.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Pantau_cctv".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: Dimensions.text24,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: () async{
      
          },
          child: CircleAvatar(
            
            radius: Dimensions.size25,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: Text(
              Formats.initials(user?["name"] ?? "I?"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: Dimensions.text20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return TextField(
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            hintText: "Search_cctv".tr(),
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.size15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: Dimensions.size15,
            ),
          ),
          onChanged: (query) {
            context.read<HomeBloc>().add(SearchCctv(query));
          },
        );
      },
    );
  }

  Widget _buildFilterButton() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! CctvDataLoaded) {
          return const SizedBox.shrink();
        }

        final locations = state.locations;
        if (locations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(Dimensions.size15),
          ),
          child: IconButton(
            icon: Icon(Icons.filter_alt_rounded, color: Colors.white),
            onPressed: () async {
              final selectedId = state.selectedLocationId;
              await BaseSheets.spinner(
                title: "filter_by_location".tr(),
                spinnerItems: [
                  SpinnerItem(
                    identity: null,
                    description: "All".tr(),
                    selected: selectedId == null,
                  ),
                  ...locations.map(
                    (loc) => SpinnerItem(
                      identity: loc.id,
                      description: loc.name,
                      selected: selectedId == loc.id,
                    ),
                  ),
                ],
                onSelected: (item) {
                  context
                      .read<HomeBloc>()
                      .add(FilterByLocation(item.identity as int?));
                },
                context: context,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (loading) {
          return Center(child: BaseWidgets.shimmer());
        }

        if (state is CctvDataLoaded) {
          final cctvs = state.cctvList;
          if (cctvs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    "assets/lottie/no_data.json",
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    "no_cctv_found".tr(),
                    style: TextStyle(
                      fontSize: Dimensions.text16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(LoadCctvData());
              context.read<HomeBloc>().add(LoadLocations());
            },
            child: CustomScrollView(
              slivers: [
                if (!isIOS)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildLiveCctvCard(
                          cctvs.firstWhere(
                            (c) => c.isActive,
                            orElse: () => cctvs.first,
                          ),
                        ),
                        SizedBox(height: Dimensions.size15),
                      ],
                    ),
                  ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                    mainAxisSpacing: Dimensions.size15,
                    crossAxisSpacing: Dimensions.size15,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCctvCard(cctvs[index]),
                    childCount: cctvs.length,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CctvDataError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error: ${state.message}",
                  style: TextStyle(color: AppColors.onSurface()),
                ),
                SizedBox(height: Dimensions.size15),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(LoadCctvData());
                    context.read<HomeBloc>().add(LoadLocations());
                  },
                  child: Text("Retry".tr()),
                ),
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCctvCard(CctvItem cctv) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Split the name into parts if it contains "FTL"
      final nameParts = cctv.name.split(" ");
      final isFtl = nameParts.contains("FTL");
      final firstLine = isFtl ? nameParts.take(2).join(" ") : nameParts.first;
      final secondLine = isFtl ? nameParts.skip(2).join(" ") : nameParts.skip(1).join(" ");

      return GestureDetector(
        onTap: cctv.isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(cctv.name)),
                      body: WebViewWidget(
                        controller: WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..loadRequest(Uri.parse(cctv.sourceUrl)),
                      ),
                    ),
                  ),
                );
              }
            : null,
        child: Opacity(
          opacity: cctv.isActive ? 1.0 : 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Dimensions.size20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Dimensions.size20),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: isIOS
                          ? _buildThumbnail(cctv.thumbnailUrl)
                          : WebViewWidget(
                              controller: WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadRequest(Uri.parse(cctv.sourceUrl)),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Dimensions.size10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFtl) ...[
                        Text(
                          firstLine,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.text16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          secondLine,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.text16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          cctv.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.text16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: Dimensions.size4),
                      Text(
                        cctv.location.name,
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Dimensions.size5),
                      Row(
                        children: [
                          Icon(
                            cctv.isActive ? Icons.check_circle : Icons.cancel,
                            color: cctv.isActive ? Colors.green : Colors.red,
                            size: Dimensions.size15,
                          ),
                          SizedBox(width: Dimensions.size5),
                          Text(
                            cctv.isActive ? "Active".tr() : "Inactive".tr(),
                            style: TextStyle(
                              color: cctv.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
 Widget _buildThumbnail(String? thumbnailUrl) {
  if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimensions.size20),
      ),
      child: Container(
        color: Colors.white.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: Dimensions.size40,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(Dimensions.size20),
    ),
    child: CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.white.withOpacity(0.1),
        child: Center(child: BaseWidgets.shimmer()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.white.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
        ),
      ),
    ),
  );
 }

  Widget _buildLiveCctvCard(CctvItem cctv) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(Dimensions.size20),
      ),
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.size20),
              ),
            ),
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(cctv.sourceUrl)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.size15,
              vertical: Dimensions.size5,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.live_tv,
                  color: Colors.red,
                  size: Dimensions.size20,
                ),
                SizedBox(width: Dimensions.size5),
                Expanded(
                  child: Text(
                    cctv.name,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
