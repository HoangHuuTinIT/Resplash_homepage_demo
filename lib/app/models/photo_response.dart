import 'package:flutter_app/app/models/photo.dart';

class PhotoResponse {
  final List<Photo> photos;
  final String? nextPageUrl;

  PhotoResponse({required this.photos, this.nextPageUrl});
}