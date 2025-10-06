import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class PhotoDetailPageController extends Controller {
  Photo? photo;

  // Hàm này sẽ được gọi từ Page để bắt đầu quá trình tải dữ liệu
  Future<void> fetchDetails(dynamic data) async {
    if (data is Photo) {
      photo = data; // Hiển thị dữ liệu cơ bản ngay lập tức
      // Sau đó tải thêm dữ liệu chi tiết ở chế độ nền
      photo = await api<ApiService>((request) => request.fetchPhotoDetails(photo!.id!));
    } else if (data is String) {
      // Nếu chỉ nhận được ID, tải tất cả dữ liệu
      photo = await api<ApiService>((request) => request.fetchPhotoDetails(data));
    }
  }
}