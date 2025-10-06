import 'package:flutter_app/app/models/user_profile_image.dart';
import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? id;
  String? name;
  String? username;
  UserProfileImage? profileImage;

  User({this.id, this.name, this.username, this.profileImage});

  User.fromJson(dynamic data) {
    id = data['id'];
    name = data['name'];
    username = data['username'];
    if (data['profile_image'] != null) {
      profileImage = UserProfileImage.fromJson(data['profile_image']);
    }
  }

  @override
  toJson() => {
    "id": id,
    "name": name,
    "username": username,
    "profile_image": profileImage?.toJson(),
  };
}
