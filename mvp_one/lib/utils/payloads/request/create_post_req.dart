import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class CreatePostRequestPayload extends BaseReq {
  String? userId;
  String? imageUrl;
  String? caption;
  // String? sound;

  CreatePostRequestPayload({
    required this.userId,
    required this.imageUrl,
    required this.caption,
    // required this.sound
  });

  @override
  String encode() {
    return jsonEncode({
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      // 'sound': sound
    });
  }
}
