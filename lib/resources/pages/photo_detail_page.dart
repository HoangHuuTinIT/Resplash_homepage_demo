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
    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Không tìm thấy ảnh hoặc có lỗi xảy ra")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildUserInfo(context, photo),
                  Divider(height: 40, thickness: 1),
                  _buildAllInfo(context, photo),
                  Divider(height: 40, thickness: 1),
                  _buildPhotoStats(context, photo),
                  SizedBox(height: 24),
                  _buildTags(context, photo),
                  SizedBox(height: 32),
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
  Widget _buildAllInfo(BuildContext context, Photo photo) {
    final exif = photo.exif;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Camera", exif?.model ?? "N/A"),
            _buildStatItem("Aperture", "f/${exif?.aperture ?? 'N/A'}"),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Focal Length", "${exif?.focalLength ?? 'N/A'}mm"),
            _buildStatItem("Shutter Speed", "${exif?.exposureTime ?? 'N/A'}s"),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("ISO", (exif?.iso ?? 0).toString()),
            _buildStatItem("Dimensions", "${photo.width ?? ''} x ${photo.height ?? ''}"),
          ],
        )
      ],
    );
  }

  Widget _buildPhotoStats(BuildContext context, Photo photo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Views", (photo.views ?? 0).toString()),
        _buildStatItem("Downloads", (photo.downloads ?? 0).toString()),
        _buildStatItem("Likes", (photo.likes ?? 0).toString()),
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
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWallpaperButton(Photo photo) {
    return Center(
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
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

}