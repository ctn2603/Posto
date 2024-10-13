import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class FriendReq extends BaseReq {
  String? senderId;
  String? receiverId;

  FriendReq({required this.senderId, required this.receiverId});

  @override
  String encode() {
    return jsonEncode({
      'sender_id': senderId,
      'receiver_id': receiverId,
    });
  }
}
