import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class PhotoDetailPageController extends Controller {
  Photo? photo;


  Future<void> fetchDetails(dynamic data) async {
    if (data is Photo) {
      photo = data;
      photo = await api<ApiService>((request) => request.fetchPhotoDetails(photo!.id!));
    } else if (data is String) {
      photo = await api<ApiService>((request) => request.fetchPhotoDetails(data));
    }
  }
}