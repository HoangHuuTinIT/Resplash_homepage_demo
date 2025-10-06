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

  @override
  get init => () async {
    // Gọi hàm fetch dữ liệu từ controller khi trang được khởi tạo
    await widget.controller.fetchInitialPhotos();
  };

  @override
  Widget view(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(getEnv("APP_NAME")),
          centerTitle: true,
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
              itemCount: widget.controller.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.controller.photos[index];
                return InkWell(
                  onTap: () => routeTo('/photo-detail', data: photo),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
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
                        Image.network(
                          photo.urls?.regular ?? "",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
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
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {}),
              SizedBox(width: 48), // Khoảng trống cho FAB
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}