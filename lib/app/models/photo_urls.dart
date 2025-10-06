import 'package:nylo_framework/nylo_framework.dart';

class PhotoUrls extends Model {
  String? raw;
  String? full;
  String? regular;
  String? small;
  String? thumb;

  PhotoUrls({this.raw, this.full, this.regular, this.small, this.thumb});

  PhotoUrls.fromJson(dynamic data) {
    raw = data['raw'];
    full = data['full'];
    regular = data['regular'];
    small = data['small'];
    thumb = data['thumb'];
  }

  @override
  toJson() => {
    "raw": raw,
    "full": full,
    "regular": regular,
    "small": small,
    "thumb": thumb,
  };
}
