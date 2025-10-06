import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/app/controllers/home_controller.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  bool _showBottomNavBar = true;

  @override
  get init => () async {
    if (widget.controller.photos.isEmpty) {
      await widget.controller.fetchInitialPhotos();
    }
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = false;
        });
      }
    } else {
      if (!_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = true;
        });
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!widget.controller.isLoadingMore) {
        widget.controller.fetchMorePhotos().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: "HOME"),
              Tab(text: "COLLECTIONS"),
            ],
          ),
        ),
        body: SafeAreaWidget(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              await widget.controller.onRefresh();
              setState(() {});
              _refreshController.refreshCompleted();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.controller.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.controller.photos[index];
                final double aspectRatio =
                (photo.width != null && photo.height != null && photo.height! > 0)
                    ? photo.width! / photo.height!
                    : 16 / 9;
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                    photo.user?.profileImage?.medium ?? ""),
                              ),
                              SizedBox(width: 12),
                              Text(
                                photo.user?.name ?? "Unknown",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
            ),
          ),
        ),
// ... các phần khác trong Scaffold giữ nguyên

        floatingActionButton: Transform.scale(
          // Dùng Transform.scale để ẩn/hiện nút mà không làm hỏng layout
          scale: _showBottomNavBar ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            elevation: 6.0, // Giữ elevation cố định hoặc cũng có thể thay đổi
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Giữ nguyên animation cho BottomAppBar
          height: _showBottomNavBar ? 60.0 : 0.0,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            // Thêm clipBehavior để nội dung không bị tràn ra ngoài khi animation
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
                    // Thêm một IconButton nữa nếu bạn muốn cân bằng
                    // IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                  ],
                )
              ],
            ),
          ),
        ),

// ...
      ),
    );
  }
}