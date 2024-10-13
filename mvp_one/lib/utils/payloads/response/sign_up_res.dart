import 'package:mvp_one/utils/payloads/response/base_res.dart';

class SignUpRes extends BaseRes {
  String? userId;
  String? username;
  String? name;
  String? profileImage;
  String? email;

  SignUpRes({
    required this.userId,
    required this.username,
    required this.name,
    required this.profileImage,
    required this.email,
  });

  factory SignUpRes.fromJson(Map<String, dynamic> json) {
    return SignUpRes(
        userId: json["id"],
        username: json['username'],
        name: json['name'],
        profileImage: json['profileImage'],
        email: json['email']);
  }
}
