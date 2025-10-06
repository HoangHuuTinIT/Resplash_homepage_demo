import 'package:nylo_framework/nylo_framework.dart';

class PhotoExif extends Model {
  String? make;
  String? model;
  String? name;
  String? exposureTime;
  String? aperture;
  String? focalLength;
  int? iso;

  PhotoExif(
      {this.make,
        this.model,
        this.name,
        this.exposureTime,
        this.aperture,
        this.focalLength,
        this.iso});

  PhotoExif.fromJson(dynamic data) {
    make = data['make'];
    model = data['model'];
    name = data['name'];
    exposureTime = data['exposure_time'];
    aperture = data['aperture'];
    focalLength = data['focal_length'];
    iso = data['iso'];
  }

  @override
  toJson() => {
    "make": make,
    "model": model,
    "name": name,
    "exposure_time": exposureTime,
    "aperture": aperture,
    "focal_length": focalLength,
    "iso": iso
  };
}
