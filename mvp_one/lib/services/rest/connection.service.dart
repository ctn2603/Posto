import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mvp_one/configs/app_uri.dart';
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/request/friend_req.dart';
import 'package:mvp_one/utils/payloads/response/friend_res.dart' as res;

class ConnectionService {
  // Fetch user connection requests
  static Future<List<res.FriendRequestsReceivedRes>?> getConnectionRequests(
      String userId) async {
    http.Response? response = await RestService.get(
        getConnectionRequestsUri.replaceAll("{userid}", userId));

    if (response?.statusCode == 200) {
      dynamic data = json.decode(response!.body);
      List<res.FriendRequestsReceivedRes> payloads = [];
      if (data['friend_requests_received'] != null) {
        for (dynamic request in data['friend_requests_received']) {
          payloads.add(res.FriendRequestsReceivedRes.fromJson(request));
        }
      }
      return payloads;
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  //fetch user connections
  static Future<List<res.FriendRes>?> getConnections(String userId) async {
    http.Response? response =
        await RestService.get(getConnectionsUri.replaceAll("{userid}", userId));

    if (response?.statusCode == 200) {
      dynamic data = json.decode(response!.body);
      List<res.FriendRes> payloads = [];
      if (data['friends'] != null) {
        for (dynamic request in data['friends']) {
          payloads.add(res.FriendRes.fromJson(request));
        }
      }
      return payloads;
      // return await jsonDecode(response!.body)["connections"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<void> sendConnectionRequest(
      String senderId, String receiverId) async {
    http.Response? response = await RestService.post(sendFriendRequestUri,
        FriendReq(senderId: senderId, receiverId: receiverId));

    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<void> acceptConnectionRequest(
      String senderId, String receiverId) async {
    http.Response? response = await RestService.post(acceptConnectionRequestUri,
        FriendReq(senderId: senderId, receiverId: receiverId));

    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<void> deleteConnectionRequest(
      String senderId, String receiverId) async {
    http.Response? response = await RestService.post(deleteConnectionRequestUri,
        FriendReq(senderId: senderId, receiverId: receiverId));

    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }
}
