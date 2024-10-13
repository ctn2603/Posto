import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class SignInReq extends BaseReq {
  String? username;
  String? password;

  SignInReq({required this.username, required this.password});

  @override
  String encode() {
    return jsonEncode({
      'username': username,
      'password': password,
    });
  }
}
