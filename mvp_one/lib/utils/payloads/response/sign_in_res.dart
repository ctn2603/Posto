import 'package:mvp_one/utils/payloads/response/base_res.dart';

class SignInRes extends BaseRes {
  String? userId;
  String? username;
  String? name;
  String? profileImage;
  String? email;

  SignInRes(
      {required this.userId,
      required this.username,
      required this.name,
      required this.profileImage,
      required this.email});

  factory SignInRes.fromJson(Map<String, dynamic> json) {
    return SignInRes(
        userId: json["id"],
        username: json['username'],
        name: json['name'],
        profileImage: json['profileImage'],
        email: json['email']);
  }
}
