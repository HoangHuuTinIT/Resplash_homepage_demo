import 'package:nylo_framework/nylo_framework.dart';

class UserProfileImage extends Model {
  String? small;
  String? medium;
  String? large;

  UserProfileImage({this.small, this.medium, this.large});

  UserProfileImage.fromJson(dynamic data) {
    small = data['small'];
    medium = data['medium'];
    large = data['large'];
  }

  @override
  toJson() => {
    "small": small,
    "medium": medium,
    "large": large,
  };
}
