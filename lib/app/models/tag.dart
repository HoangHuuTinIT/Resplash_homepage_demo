import 'package:nylo_framework/nylo_framework.dart';

class Tag extends Model {
  String? title;

  Tag({this.title});

  Tag.fromJson(dynamic data) {
    title = data['title'];
  }

  @override
  toJson() => {"title": title};
}
