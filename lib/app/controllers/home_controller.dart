// lib/app/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  // ✅ 1. Chuyển List<Photo> thành ValueNotifier
  final ValueNotifier<List<Photo>> photos = ValueNotifier([]);
  int _page = 1;
  bool isLoadingMore = false;

  final ValueNotifier<bool> showBottomNavBar = ValueNotifier(true);

  Future<void> fetchInitialPhotos() async {
    _page = 1;
    // ✅ 2. Cập nhật dữ liệu thông qua .value
    photos.value = await api<ApiService>((request) => request.fetchPhotos(page: _page)) ?? [];
  }

  Future<void> fetchMorePhotos() async {
    if (isLoadingMore) return;

    isLoadingMore = true;
    _page++;

    List<Photo>? newPhotos = await api<ApiService>((request) => request.fetchPhotos(page: _page));
    if (newPhotos != null && newPhotos.isNotEmpty) {
      // ✅ 3. Thêm ảnh mới và gán lại vào .value để thông báo cho UI
      photos.value = List.from(photos.value)..addAll(newPhotos);
    }

    isLoadingMore = false;
  }

  Future<void> onRefresh() async {
    await fetchInitialPhotos();
  }

  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (showBottomNavBar.value) {
        showBottomNavBar.value = false;
        // ✅ THÊM DÒNG NÀY: Tạo một list mới để kích hoạt ValueListenableBuilder bên ngoài
        photos.value = List.from(photos.value);
      }
    } else {
      if (!showBottomNavBar.value) {
        showBottomNavBar.value = true;
        // ✅ THÊM DÒNG NÀY: Tạo một list mới để kích hoạt ValueListenableBuilder bên ngoài
        photos.value = List.from(photos.value);
      }
    }

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.9) {
      fetchMorePhotos();
    }
  }

  void scrollToTop(ScrollController scrollController) {
    if (scrollController.hasClients) {
      // Luôn sử dụng animateTo để cuộn về đầu trang một cách mượt mà
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}