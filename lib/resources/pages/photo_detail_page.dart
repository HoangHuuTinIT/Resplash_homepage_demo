// lib/resources/pages/photo_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/photo_detail_page_controller.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/resources/widgets/photo_info_section.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PhotoDetailPage extends NyStatefulWidget<PhotoDetailPageController> {
  static RouteView path = ("/photo-detail", (_) => PhotoDetailPage());

  PhotoDetailPage({super.key}) : super(child: () => _PhotoDetailPageState());
}

class _PhotoDetailPageState extends NyPage<PhotoDetailPage> {

  @override
  get init => () {
    widget.controller.setupInitial(widget.data());
  };

  @override
  Widget view(BuildContext context) {
    final Photo initialPhoto = widget.controller.photo!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                // PHẦN TĨNH: HÌNH ẢNH (KHÔNG BAO GIỜ REBUILD)
                Image.network(
                  initialPhoto.urls?.regular ?? "",
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // ✅ PHẦN ĐỘNG: LOCATION (CHỈ REBUILD KHI CÓ DỮ LIỆU)
                ValueListenableBuilder<Photo?>(
                  valueListenable: widget.controller.photoNotifier,
                  builder: (context, photo, child) {
                    // Chỉ hiển thị khi có dữ liệu location
                    if (photo?.location?.country == null) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              photo!.location!.country!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // TOÀN BỘ THÔNG TIN CHI TIẾT CÒN LẠI
            PhotoInfoSection(
              controller: widget.controller,
            ),
          ],
        ),
      ),
    );
  }
}