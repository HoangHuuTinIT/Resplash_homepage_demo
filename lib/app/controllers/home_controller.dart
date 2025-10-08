// lib/app/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/app/models/photo_response.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  final ValueNotifier<List<Photo>> photos = ValueNotifier([]);
  String? _nextPageUrl;
  bool isLoadingMore = false;

  final ValueNotifier<bool> showBottomNavBar = ValueNotifier(true);

  Future<void> fetchInitialPhotos() async {
    PhotoResponse? response =
    await api<ApiService>((request) => request.fetchPhotos());
    if (response != null) {
      photos.value = response.photos;
      _nextPageUrl = response.nextPageUrl;
    }
  }

  Future<void> fetchMorePhotos() async {
    if (isLoadingMore || _nextPageUrl == null) return;

    isLoadingMore = true;
    PhotoResponse? response = await api<ApiService>(
            (request) => request.fetchPhotos(url: _nextPageUrl));

    if (response != null) {
      photos.value = List.from(photos.value)..addAll(response.photos);
      _nextPageUrl = response.nextPageUrl;
    }
    isLoadingMore = false;
  }

  Future<void> onRefresh() async {
    await fetchInitialPhotos();
  }

  // Các hàm handleScroll và scrollToTop giữ nguyên, không cần thay đổi
  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (showBottomNavBar.value) {
        showBottomNavBar.value = false;
        photos.value = List.from(photos.value);
      }
    } else {
      if (!showBottomNavBar.value) {
        showBottomNavBar.value = true;
        photos.value = List.from(photos.value);
      }
    }

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMorePhotos();
    }
  }

  void scrollToTop(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}