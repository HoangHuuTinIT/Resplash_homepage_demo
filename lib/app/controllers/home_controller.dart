import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  List<Photo> photos = [];
  int _page = 1;
  bool isLoadingMore = false;

  Future<void> fetchInitialPhotos() async {
    _page = 1;
    photos = await api<ApiService>((request) => request.fetchPhotos(page: _page)) ?? [];
  }

  Future<void> fetchMorePhotos() async {
    if (isLoadingMore) return;

    isLoadingMore = true;
    _page++;

    List<Photo>? newPhotos = await api<ApiService>((request) => request.fetchPhotos(page: _page));
    if (newPhotos != null && newPhotos.isNotEmpty) {
      photos.addAll(newPhotos);
    }

    isLoadingMore = false;
  }

  Future<void> onRefresh() async {
    await fetchInitialPhotos();
  }
}