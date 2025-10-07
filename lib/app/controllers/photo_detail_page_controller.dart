import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class PhotoDetailPageController extends Controller {
  // ✅ SỬ DỤNG VALUENOTIFIER ĐỂ THÔNG BÁO THAY ĐỔI
  final ValueNotifier<Photo?> photoNotifier = ValueNotifier(null);

  // Vẫn giữ lại biến photo để truy cập tiện lợi
  Photo? get photo => photoNotifier.value;
  set photo(Photo? newPhoto) {
    photoNotifier.value = newPhoto;
  }

  /// Thiết lập dữ liệu ban đầu được truyền từ trang chủ.
  void setupInitial(dynamic data) {
    if (data is Photo) {
      // Chỉ gán nếu photo đang là null (chạy lần đầu)
      if (photo == null) {
        photo = data;
      }
    }
  }

  /// Tải dữ liệu chi tiết đầy đủ từ API trong nền.
  Future<void> fetchFullDetails() async {
    if (photo == null || photo!.id == null) return;

    Photo? fullDetailsPhoto =
    await api<ApiService>((request) => request.fetchPhotoDetails(photo!.id!));

    if (fullDetailsPhoto != null) {
      // ✅ Gán giá trị mới, việc này sẽ tự động thông báo cho các widget đang "lắng nghe"
      photo = fullDetailsPhoto;
    }
  }
}