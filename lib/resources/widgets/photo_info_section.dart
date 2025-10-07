import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/photo_detail_page_controller.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoInfoSection extends StatefulWidget {
  final PhotoDetailPageController controller;
  final VoidCallback onDetailsLoaded;
  const PhotoInfoSection({Key? key, required this.controller,required this.onDetailsLoaded, }) : super(key: key);

  @override
  _PhotoInfoSectionState createState() => _PhotoInfoSectionState();
}

class _PhotoInfoSectionState extends State<PhotoInfoSection> {
  bool _detailsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    await widget.controller.fetchFullDetails();
    if (mounted) {
      setState(() {
        _detailsLoaded = true;
      });
      widget.onDetailsLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Luôn lấy photo object mới nhất từ controller
    final Photo photo = widget.controller.photo!;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        // Nếu chưa load xong details, hiện loader. Ngược lại, hiện toàn bộ thông tin.
        child: !_detailsLoaded
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: CupertinoActivityIndicator(radius: 14),
          ),
        )
            : Column(
          children: [
            _buildUserInfo(context, photo),
            const Divider(height: 40, thickness: 1),
            _buildAllInfo(context, photo),
            const Divider(height: 40, thickness: 1),
            _buildPhotoStats(context, photo),
            const SizedBox(height: 24),
            _buildTags(context, photo),
            const SizedBox(height: 32),
            _buildWallpaperButton(photo),
          ],
        ),
      ),
    );
  }

  // TẤT CẢ CÁC HÀM _build... ĐƯỢC CHUYỂN TỪ PHOTO_DETAIL_PAGE SANG ĐÂY

  Widget _buildUserInfo(BuildContext context, Photo photo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(photo.user?.profileImage?.medium ?? ""),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            photo.user?.name ?? "Unknown",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(icon: Icon(Icons.download_outlined, color: Colors.black54), onPressed: () {}),
        IconButton(icon: Icon(Icons.favorite_border, color: Colors.black54), onPressed: () {}),
        IconButton(icon: Icon(Icons.bookmark_border, color: Colors.black54), onPressed: () {}),
      ],
    );
  }

  Widget _buildAllInfo(BuildContext context, Photo photo) {
    final exif = photo.exif;
    String formatValue(String? value, {String prefix = "", String suffix = ""}) {
      if (value == null || value.isEmpty) return "Unknown";
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

  Widget _buildPhotoStats(BuildContext context, Photo photo) {
    String formatNumber(num? value) {
      if (value == null) return "0";
      return value < 1000 ? value.toStringAsFixed(0) : "${(value / 1000).toStringAsFixed(1)}K";
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWallpaperButton(Photo photo) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () async {
          final Uri url = Uri.parse("https://unsplash.com/photos/${photo.id}");
          // if (!await launchUrl(url)) {
          //   showToastOops(description: 'Could not launch $url');
          // }
        },
        icon: Icon(Icons.wallpaper, color: Colors.white),
        label: Text("SET AS WALLPAPER", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}