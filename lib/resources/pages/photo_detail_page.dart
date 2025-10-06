import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/photo_detail_page_controller.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoDetailPage extends NyStatefulWidget<PhotoDetailPageController> {
  static RouteView path = ("/photo-detail", (_) => PhotoDetailPage());

  PhotoDetailPage({super.key}) : super(child: () => _PhotoDetailPageState());
}

class _PhotoDetailPageState extends NyPage<PhotoDetailPage> {
  @override
  get init => () async {
    // Lấy dữ liệu được truyền từ HomePage và gọi controller để xử lý
    await widget.controller.fetchDetails(widget.data());
  };

  /// SỬA LỖI: Đổi tên 'afterLoad()' thành 'view(BuildContext context)'
  /// Đây là phương thức đúng để xây dựng UI trong NyPage
  @override
  Widget view(BuildContext context) {
    final Photo? photo = widget.controller.photo;
    if (photo == null) {
      // Nylo sẽ hiển thị màn hình loading mặc định trong khi init chạy,
      // nhưng chúng ta vẫn nên kiểm tra null để phòng trường hợp API lỗi.
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Không tìm thấy ảnh hoặc có lỗi xảy ra")),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                photo.urls?.regular ?? "",
                fit: BoxFit.cover,
                // Thêm frameBuilder để có hiệu ứng mờ dần đẹp mắt khi ảnh tải
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {},
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(context, photo),
                  SizedBox(height: 24),
                  _buildPhotoStats(context, photo),
                  SizedBox(height: 24),
                  _buildExifInfo(context, photo),
                  SizedBox(height: 24),
                  _buildTags(context, photo),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // API không trả về trường "links", tạm thời hardcode
                        final Uri url =
                        Uri.parse("https://unsplash.com/photos/${photo.id}");
                        if (!await launchUrl(url)) {
                          showToastOops(description: 'Could not launch $url');
                        }
                      },
                      icon: Icon(Icons.wallpaper),
                      label: Text("SET AS WALLPAPER"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Photo photo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(photo.user?.profileImage?.medium ?? ""),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            photo.user?.name ?? "Unknown",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(icon: Icon(Icons.download_outlined), onPressed: () {}),
        IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
        IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
      ],
    );
  }

  Widget _buildPhotoStats(BuildContext context, Photo photo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Views", (photo.views ?? 0).toString()),
        _buildStatItem("Downloads", (photo.downloads ?? 0).toString()),
        _buildStatItem("Likes", (photo.likes ?? 0).toString()),
      ],
    );
  }

  Widget _buildExifInfo(BuildContext context, Photo photo) {
    final exif = photo.exif;
    if (exif == null) return SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildStatItem("Camera", exif.model ?? "N/A")),
        Expanded(
            child: _buildStatItem("Aperture", "f/${exif.aperture ?? 'N/A'}")),
        Expanded(
            child: _buildStatItem(
                "Focal Length", "${exif.focalLength ?? 'N/A'}mm")),
        Expanded(
            child: _buildStatItem(
                "Shutter Speed", "${exif.exposureTime ?? 'N/A'}s")),
        Expanded(child: _buildStatItem("ISO", (exif.iso ?? 0).toString())),
      ],
    );
  }

  Widget _buildTags(BuildContext context, Photo photo) {
    if (photo.tags == null || photo.tags!.isEmpty) return SizedBox.shrink();
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: photo.tags!
          .map((tag) => Chip(label: Text(tag.title?.capitalize() ?? "")))
          .toList(),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}