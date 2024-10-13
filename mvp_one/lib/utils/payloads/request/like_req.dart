import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class LikeReq extends BaseReq {
  String? postId;
  String? userId;

  LikeReq({required this.postId, required this.userId});

  @override
  String encode() {
    return jsonEncode({'postId': postId, 'userId': userId});
  }
}
