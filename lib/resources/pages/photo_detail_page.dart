import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/photo_detail_page_controller.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/resources/widgets/photo_info_section.dart'; // ✅ IMPORT WIDGET MỚI
import 'package:nylo_framework/nylo_framework.dart';

class PhotoDetailPage extends NyStatefulWidget<PhotoDetailPageController> {
  static RouteView path = ("/photo-detail", (_) => PhotoDetailPage());

  PhotoDetailPage({super.key}) : super(child: () => _PhotoDetailPageState());
}

class _PhotoDetailPageState extends NyPage<PhotoDetailPage> {
  // Bỏ hàm init đi, chúng ta không cần nó nữa
  bool _detailsLoaded = false;
  @override
  get init => () {
    // Thao tác này chỉ chạy 1 lần duy nhất khi page được khởi tạo.
    widget.controller.setupInitial(widget.data());
  };
  @override
  Widget view(BuildContext context) {

    final Photo? photo = widget.controller.photo;

    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Đang tải dữ liệu...")),
      );
    }

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
            // PHẦN GIAO DIỆN TĨNH (SẼ KHÔNG BỊ "CHỚP" LẠI)
            Stack(
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
                ValueListenableBuilder<Photo?>(
                    valueListenable: widget.controller.photoNotifier,
                    builder: (context, updatedPhoto, child) {
                      // Lấy photo mới nhất từ controller để đảm bảo có thông tin location
                      final currentPhoto = updatedPhoto ?? photo;
                      if (currentPhoto.location?.displayName == null) {
                        return SizedBox.shrink();
                      }

                      return Positioned(
                        bottom: 12,
                        left: 12,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _detailsLoaded ? 1.0 : 0.0,
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
                                  currentPhoto.location!.displayName!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ],
            ),

            // PHẦN GIAO DIỆN ĐỘNG (SẼ TỰ QUẢN LÝ TRẠNG THÁI VÀ ANIMATION)
            PhotoInfoSection(
              controller: widget.controller,
              onDetailsLoaded: () {
                if(mounted) {
                  setState(() {
                    _detailsLoaded = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}