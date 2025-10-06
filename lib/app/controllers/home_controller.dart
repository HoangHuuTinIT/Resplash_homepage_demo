import 'package:nylo_framework/nylo_framework.dart';
import '../models/photo.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class HomeController extends Controller {
  List<Photo> photos = [];

  // Hàm này sẽ được gọi từ HomePage để lấy dữ liệu ban đầu
  Future<void> fetchInitialPhotos() async {
    photos = await api<ApiService>((request) => request.fetchPhotos()) ?? [];
  }

  Future<void> onRefresh() async {
    // Gọi API để lấy dữ liệu mới khi người dùng kéo để làm mới
    photos =
        await api<ApiService>((request) => request.fetchPhotos(perPage: 30)) ??
            [];
  }
}