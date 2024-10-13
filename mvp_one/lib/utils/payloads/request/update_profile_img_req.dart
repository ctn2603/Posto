import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class UpdateProfileImageReq extends BaseReq {
  String? imgUrl;

  UpdateProfileImageReq({required this.imgUrl});

  @override
  String encode() {
    return jsonEncode({
      'img_url': imgUrl,
    });
  }
}
