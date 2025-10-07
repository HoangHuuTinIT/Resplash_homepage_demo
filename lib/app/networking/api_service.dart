import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ApiService extends NyApiService {
  ApiService({BuildContext? buildContext})
      : super(
    buildContext,
    decoders: modelDecoders,
  );

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  get interceptors => {
    if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
  };

  Future<List<Photo>?> fetchPhotos({int page = 1, int perPage = 20}) async {
    return await network<List<Photo>>(
      request: (request) => request.get(
        "/photos",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
          "page": page,
          "per_page": perPage,
        },
      ),
      // cacheKey: "photos_page_$page",
      // cacheDuration: Duration(minutes: 4),
    );
  }

  Future<Photo?> fetchPhotoDetails(String photoId) async {
    return await network<Photo>(
      request: (request) => request.get(
        "/photos/$photoId",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
        },
      ),
      // cacheKey: "photo_details_$photoId",
      // cacheDuration: Duration(minutes: 4),
    );
  }
}