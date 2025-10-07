import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/app/controllers/home_controller.dart';
import 'package:flutter_app/app/models/photo.dart';
// import 'package:flutter_app/resources/widgets/safearea_widget.dart'; // XÓA HOẶC COMMENT DÒNG NÀY
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  int _bottomNavIndex = 0;
  final List<IconData> iconList = [
    Icons.menu,
    Icons.search,
    Icons.sort,
  ];

  @override
  get init => () async {
    if (widget.controller.photos.value.isEmpty) {
      await widget.controller.fetchInitialPhotos();
    }
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.controller.handleScroll(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    // const double bottomBarHeight = 0.0; // Biến này không được sử dụng, có thể xóa

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // ==========================================================
        // THÊM extendBody: true để body kéo dài ra phía sau BottomNavigationBar
        extendBody: true,
        // Đặt màu nền của Scaffold là trong suốt hoặc màu trắng để không chặn
        // Nếu ảnh của bạn có màu chủ đạo, có thể đặt màu đó ở đây
        backgroundColor: Colors.white, // Hoặc Colors.transparent nếu muốn trong suốt hoàn toàn
        // ==========================================================
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          bottom: TabBar(
            onTap: (index) {
              if (index == 0) {
                widget.controller.scrollToTop(_scrollController);
              }
            },
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: "HOME"),
              Tab(text: "COLLECTIONS"),
            ],
          ),
        ),
        // ==========================================================
        // XÓA SafeAreaWidget ở đây
        // body: SafeAreaWidget( // Bỏ dòng này
        //   child: SmartRefresher( // Giữ lại SmartRefresher
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () async {
            await widget.controller.onRefresh();
            _refreshController.refreshCompleted();
          },
          child: ValueListenableBuilder<List<Photo>>(
            valueListenable: widget.controller.photos,
            builder: (context, photoList, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: widget.controller.showBottomNavBar,
                builder: (context, show, _) {
                  // Điều chỉnh padding bottom DỰA TRÊN trạng thái hiển thị của BottomNavBar
                  double bottomPadding = show ? 90.0 : 0.0;
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    controller: _scrollController,
                    itemCount: photoList.length,
                    itemBuilder: (context, index) {
                      final photo = photoList[index];
                      final double aspectRatio = (photo.width != null &&
                          photo.height != null &&
                          photo.height! > 0)
                          ? photo.width! / photo.height!
                          : 16 / 9;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: InkWell(
                          onTap: () => routeTo('/photo-detail', data: photo),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          photo.user?.profileImage?.medium ??
                                              ""),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      photo.user?.name ?? "Unknown",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: Image.network(
                                    photo.urls?.small ?? "",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        // ==========================================================
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: widget.controller.showBottomNavBar,
            builder: (context, show, child) {
              return AnimatedScale(
                scale: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                child: child!,
              );
            },
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              elevation: 6.0,
              child: const Icon(Icons.add, color: Colors.white),
            )),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: widget.controller.showBottomNavBar,
          builder: (context, show, child) {
            return IgnorePointer(
              ignoring: !show,
              child: AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: show ? Offset.zero : const Offset(0, 1),
                  child: AnimatedBottomNavigationBar.builder(
                    itemCount: 4,
                    tabBuilder: (int index, bool isActive) {
                      final realIcons = [Icons.menu, Icons.search, Icons.sort];
                      if (index == 0) {
                        return Icon(realIcons[0], size: 24);
                      } else if (index == 1) {
                        return SizedBox.shrink();
                      } else if (index == 2) {
                        return Icon(realIcons[1], size: 24);
                      } else {
                        return Icon(realIcons[2], size: 24);
                      }
                    },
                    activeIndex: _bottomNavIndex > 0 ? _bottomNavIndex + 1 : _bottomNavIndex,
                    gapLocation: GapLocation.center,
                    notchSmoothness: NotchSmoothness.softEdge,
                    onTap: (index) {
                      if (index == 1) return;
                      int realIndex = index > 1 ? index - 1 : index;
                      setState(() => _bottomNavIndex = realIndex);
                    },
                    backgroundColor: Colors.white,
                    shadow: BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}