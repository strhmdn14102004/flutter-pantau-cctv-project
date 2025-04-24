// ignore_for_file: deprecated_member_use

import "dart:convert";

import "package:base/base.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";
import "package:cctv_sasat/helper/formats.dart";
import "package:cctv_sasat/module/home/home_bloc.dart";
import "package:cctv_sasat/module/home/home_event.dart";
import "package:cctv_sasat/module/home/home_state.dart";
import "package:flutter/material.dart";
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

  @override
  void initState() {
    super.initState();
    loadUserData();
    // Trigger initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadCctvData());
      context.read<HomeBloc>().add(LoadLocations());
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
      child: Scaffold(
        backgroundColor: AppColors.surface(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.size15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: Dimensions.size15),
                _buildSearchField(),
                SizedBox(height: Dimensions.size15),
                _buildLocationFilter(),
                SizedBox(height: Dimensions.size15),
                Text(
                  "CCTV List",
                  style: TextStyle(
                    color: AppColors.onSurface(),
                    fontSize: Dimensions.text20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Dimensions.size10),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Pantau CCTV",
          style: TextStyle(
            color: AppColors.onSurface(),
            fontSize: Dimensions.text24,
            fontWeight: FontWeight.bold,
          ),
        ),
        CircleAvatar(
          radius: Dimensions.size25,
          backgroundColor: AppColors.surfaceContainerHighest(),
          child: Text(
            Formats.initials(user?["name"] ?? "U"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(),
              fontSize: Dimensions.text20,
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
          style: TextStyle(color: AppColors.onSurface()),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainer(),
            hintText: "Search CCTV...",
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant()),
            prefixIcon: Icon(Icons.search, color: AppColors.outline()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.size10),
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

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: Dimensions.size50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: locations.length + 1,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: Dimensions.size5),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: Text(
                          "All",
                          style: TextStyle(color: AppColors.onSurface()),
                        ),
                        selected: selectedId == null,
                        onSelected: (_) {
                          context.read<HomeBloc>().add(FilterByLocation(null));
                        },
                        selectedColor: AppColors.primary(),
                        backgroundColor: AppColors.surfaceContainer(),
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: Dimensions.size15),
                      );
                    }

                    final location = locations[index - 1];
                    return ChoiceChip(
                      label: Text(
                        location.name,
                        style: TextStyle(color: AppColors.onSurface()),
                      ),
                      selected: selectedId == location.id,
                      onSelected: (_) {
                        context
                            .read<HomeBloc>()
                            .add(FilterByLocation(location.id));
                      },
                      selectedColor: AppColors.primary(),
                      backgroundColor: AppColors.surfaceContainer(),
                      labelPadding:
                          EdgeInsets.symmetric(horizontal: Dimensions.size15),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_alt, color: AppColors.onSurface()),
              onPressed: () async {
                await BaseSheets.spinner(
                  title: "Filter Location",
                  spinnerItems: [
                    SpinnerItem(
                      identity: null,
                      description: "All",
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
          ],
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
                    "assets/lottie/error.json",
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    "Tidak ada CCTV ditemukan",
                    style: TextStyle(
                      fontSize: Dimensions.text16,
                      color: AppColors.onSurface(),
                    ),
                  ),
                ],
              ),
            );
          }

          final randomActive = cctvs.firstWhere(
            (c) => c.isActive,
            orElse: () => cctvs.first,
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(LoadCctvData());
              context.read<HomeBloc>().add(LoadLocations());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildLiveCctvCard(randomActive),
                      SizedBox(height: Dimensions.size15),
                    ],
                  ),
                ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Dimensions.size15,
                    mainAxisSpacing: Dimensions.size15,
                    childAspectRatio: 0.85,
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
                  child: Text("Retry"),
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
            color: AppColors.surfaceContainer(),
            borderRadius: BorderRadius.circular(Dimensions.size20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimensions.size20),
                ),
                child: cctv.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: cctv.thumbnailUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 100,
                          color: AppColors.surfaceContainerHigh(),
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.onSurface(),
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: AppColors.surfaceContainerHigh(),
                        child: Icon(
                          Icons.videocam,
                          size: 40,
                          color: AppColors.onSurface(),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimensions.size10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cctv.name,
                      style: TextStyle(
                        color: AppColors.onSurface(),
                        fontSize: Dimensions.text16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Dimensions.size4),
                    Text(
                      cctv.location.name,
                      style: TextStyle(color: AppColors.onSurfaceVariant()),
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
                          cctv.isActive ? "Active" : "Inactive",
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
  }

  Widget _buildLiveCctvCard(CctvItem cctv) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(),
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
                Icon(Icons.live_tv, color: Colors.red, size: Dimensions.size20),
                SizedBox(width: Dimensions.size5),
                Expanded(
                  child: Text(
                    cctv.name,
                    style: TextStyle(color: AppColors.onSurface()),
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
