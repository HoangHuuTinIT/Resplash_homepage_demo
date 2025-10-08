// lib/app/networking/api_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/photo.dart';
import 'package:flutter_app/app/models/photo_response.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:dio/dio.dart' as dio_instance;

class ApiService extends NyApiService {
  late final dio_instance.Dio _dio;

  ApiService({BuildContext? buildContext}) : super(buildContext) {
    _dio = dio_instance.Dio(
      dio_instance.BaseOptions(
        baseUrl: getEnv('API_BASE_URL'),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    if (getEnv('APP_DEBUG') == true) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  Future<PhotoResponse?> fetchPhotos({String? url}) async {
    try {
      final dio_instance.Response response;
      if (url != null) {
        response = await _dio.get(url);
      } else {
        response = await _dio.get(
          "/photos",
          queryParameters: {
            "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
            "page": 1,
            "per_page": 20,
          },
        );
      }

      List<Photo> photos =
      List.from(response.data).map((json) => Photo.fromJson(json)).toList();

      String? nextPageUrl;
      final linkHeader = response.headers.value('Link');
      if (linkHeader != null) {
        final links = linkHeader.split(', ');
        try {
          final nextLink = links.firstWhere(
                (link) => link.contains('rel="next"'),
          );
          nextPageUrl = nextLink.substring(1, nextLink.indexOf('>'));
        } catch (_) {
          nextPageUrl = null;
        }
      }

      return PhotoResponse(photos: photos, nextPageUrl: nextPageUrl);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }

  // SỬA LỖI Ở ĐÂY: Dùng _dio thay vì network()
  Future<Photo?> fetchPhotoDetails(String photoId) async {
    try {
      final response = await _dio.get(
        "/photos/$photoId",
        queryParameters: {
          "client_id": getEnv('UNSPLASH_ACCESS_KEY'),
        },
      );
      // Giải mã dữ liệu thủ công
      return Photo.fromJson(response.data);
    } on dio_instance.DioException catch (e) {
      NyLogger.error(e.toString());
      return null;
    }
  }
}