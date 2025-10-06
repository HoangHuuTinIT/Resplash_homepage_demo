import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
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

                final double aspectRatio = (photo.width != null && photo.height != null && photo.height! > 0)
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.black,
          child: Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {}),
              SizedBox(width: 48),
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}