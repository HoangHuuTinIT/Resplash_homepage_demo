import 'package:flutter_app/app/models/photo_exif.dart';
import 'package:flutter_app/app/models/photo_urls.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Photo extends Model {
  String? id;
  String? description;
  PhotoUrls? urls;
  User? user;
  int? likes;
  int? downloads;
  int? views;
  PhotoExif? exif;
  List<Tag>? tags;

  Photo(
      {this.id,
        this.description,
        this.urls,
        this.user,
        this.likes,
        this.downloads,
        this.views,
        this.exif,
        this.tags});

  Photo.fromJson(dynamic data) {
    id = data['id'];
    description = data['description'];
    likes = data['likes'];
    downloads = data['downloads'];
    views = data['views'];

    if (data['urls'] != null) {
      urls = PhotoUrls.fromJson(data['urls']);
    }
    if (data['user'] != null) {
      user = User.fromJson(data['user']);
    }
    if (data['exif'] != null) {
      exif = PhotoExif.fromJson(data['exif']);
    }
    if (data['tags'] != null) {
      tags = List.from(data['tags']).map((t) => Tag.fromJson(t)).toList();
    }
  }

  @override
  toJson() => {
    "id": id,
    "description": description,
    "likes": likes,
    "downloads": downloads,
    "views": views,
    "urls": urls?.toJson(),
    "user": user?.toJson(),
    "exif": exif?.toJson(),
    "tags": tags?.map((t) => t.toJson()).toList(),
  };
}

class Tag extends Model {
  String? title;

  Tag({this.title});

  Tag.fromJson(dynamic data) {
    title = data['title'];
  }

  @override
  toJson() => {"title": title};
}
