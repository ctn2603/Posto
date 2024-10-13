import 'dart:convert';

import 'package:mvp_one/configs/app_config.dart';
import 'package:mvp_one/utils/payloads/request/base_req.dart';

class SignUpReq extends BaseReq {
  String? name;
  String? username;
  String? password;
  String? email;
  String? phone;
  String? profileImage;
  String? userId;

  SignUpReq(
      {required this.name,
      required this.username,
      required this.password,
      required this.email,
      required this.phone,
      required this.profileImage,
      required this.userId});

  @override
  String encode() {
    return jsonEncode({
      'name': name,
      'username': username,
      'password': password!,
      'email': email,
      'phone': phone!,
      'profileImage': (profileImage != null && profileImage!.isNotEmpty)
          ? profileImage!
          : defaultProfileUri,
      'id': userId,
    });
  }
}
