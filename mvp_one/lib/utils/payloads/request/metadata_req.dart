import 'dart:convert';

import 'package:mvp_one/utils/payloads/request/base_req.dart';

class OnboardReq extends BaseReq {
  String? userId;

  OnboardReq({required this.userId});

  @override
  String encode() {
    return jsonEncode({'userId': userId});
  }
}

class AcknowledgeSquareReq extends BaseReq {
  String? userId;

  AcknowledgeSquareReq({required this.userId});

  @override
  String encode() {
    return jsonEncode({'userId': userId});
  }
}

class AcknowledgeTermsAndConditionsReq extends BaseReq {
  String? userId;

  AcknowledgeTermsAndConditionsReq({required this.userId});

  @override
  String encode() {
    return jsonEncode({'user_id': userId});
  }
}

class AcknowledgeCampusReq extends BaseReq {
  String? userId;

  AcknowledgeCampusReq({required this.userId});

  @override
  String encode() {
    return jsonEncode({'userId': userId});
  }
}

class AcknowledgePlaygroundReq extends BaseReq {
  String? userId;

  AcknowledgePlaygroundReq({required this.userId});

  @override
  String encode() {
    return jsonEncode({'userId': userId});
  }
}
