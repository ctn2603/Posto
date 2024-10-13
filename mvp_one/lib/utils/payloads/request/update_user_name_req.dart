import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class UpdateUserNameReq extends BaseReq {
  String? username;

  UpdateUserNameReq({required this.username});

  @override
  String encode() {
    return jsonEncode({
      'username': username,
    });
  }
}

class UpdateNameReq extends BaseReq {
  String? name;

  UpdateNameReq({required this.name});

  @override
  String encode() {
    return jsonEncode({
      'name': name,
    });
  }
}
