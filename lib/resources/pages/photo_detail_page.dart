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
    await widget.controller.fetchDetails(widget.data());
  };
  @override
  Widget view(BuildContext context) {
    final Photo? photo = widget.controller.photo;
    double viewPhoto = 0;
    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Không tìm thấy ảnh hoặc có lỗi xảy ra")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Cho phép ảnh nền tràn qua AppBar
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Làm nền AppBar trong suốt
        elevation: 0, // ✅ Xóa bóng đổ
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // ✅ Ảnh nền tràn luôn qua AppBar
                Image.network(
                  photo.urls?.regular ?? "",
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
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

                // Hiển thị vị trí (nếu có)
                if (photo.location?.displayName != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            photo.location!.displayName!,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Phần nội dung bên dưới ảnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildUserInfo(context, photo),
                  const Divider(height: 40, thickness: 1),
                  _buildAllInfo(context, photo),
                  const Divider(height: 40, thickness: 1),
                  _buildPhotoStats(context, photo, viewPhoto),
                  const SizedBox(height: 24),
                  _buildTags(context, photo),
                  const SizedBox(height: 32),
                  _buildWallpaperButton(photo),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildUserInfo(BuildContext context, Photo photo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
          NetworkImage(photo.user?.profileImage?.medium ?? ""),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            photo.user?.name ?? "Unknown",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
            icon: Icon(Icons.download_outlined, color: Colors.black54),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black54),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black54),
            onPressed: () {}),
      ],
    );
  }

  // SỬA ĐỔI: Sử dụng bố cục 3 hàng, 2 cột theo yêu cầu của bạn
  Widget _buildAllInfo(BuildContext context, Photo photo) {
    final exif = photo.exif;

    // Hàm helper để định dạng giá trị
    String formatValue(String? value, {String prefix = "", String suffix = ""}) {
      if (value == null || value.isEmpty) {
        return "Unknown";
      }
      return "$prefix$value$suffix";
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStatItem("Camera", exif?.model ?? "Unknown", align: CrossAxisAlignment.start)),
            Expanded(child: _buildStatItem("Aperture", formatValue(exif?.aperture, prefix: "f/"), align: CrossAxisAlignment.start)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStatItem("Focal Length", formatValue(exif?.focalLength, suffix: "mm"), align: CrossAxisAlignment.start)),
            Expanded(child: _buildStatItem("Shutter Speed", formatValue(exif?.exposureTime, suffix: "s"), align: CrossAxisAlignment.start)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStatItem("ISO", (exif?.iso ?? 'Unknown').toString(), align: CrossAxisAlignment.start)),
            Expanded(child: _buildStatItem("Dimensions", "${photo.width ?? 'Unknown'}x${photo.height ?? ''}", align: CrossAxisAlignment.start)),
          ],
        )
      ],
    );
  }

  Widget _buildPhotoStats(BuildContext context, Photo photo, double viewPhoto) {
    String formatNumber(num? value) {
      if (value == null) return "0";
      return value < 1000
          ? value.toStringAsFixed(0)
          : "${(value / 1000).toStringAsFixed(1)}K";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Views", formatNumber(photo.views)),
        _buildStatItem("Downloads", formatNumber(photo.downloads)),
        _buildStatItem("Likes", formatNumber(photo.likes)),
      ],
    );
  }


  Widget _buildTags(BuildContext context, Photo photo) {
    if (photo.tags == null || photo.tags!.isEmpty) return SizedBox.shrink();
    return Container(
      height: 35,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: photo.tags!
              .map((tag) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              label: Text(tag.title?.capitalize() ?? ""),
              backgroundColor: Colors.grey[200],
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {CrossAxisAlignment align = CrossAxisAlignment.center}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // SỬA ĐỔI: Bọc nút bấm trong Align để đẩy sang phải
  Widget _buildWallpaperButton(Photo photo) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () async {
          final Uri url = Uri.parse("https://unsplash.com/photos/${photo.id}");
          if (!await launchUrl(url)) {
            showToastOops(description: 'Could not launch $url');
          }
        },
        icon: Icon(Icons.wallpaper, color: Colors.white),
        label: Text("SET AS WALLPAPER", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}