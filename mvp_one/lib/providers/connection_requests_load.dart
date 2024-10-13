import 'package:flutter/material.dart';
import 'package:mvp_one/services/rest/connection.service.dart';
import 'package:mvp_one/utils/payloads/response/friend_res.dart' as res;

class ConnectionRequestsLoad extends ChangeNotifier {
  List<res.FriendRequestsReceivedRes> _requests = [];
  List<res.FriendRes> _connections = [];

  // public getters
  List<res.FriendRequestsReceivedRes> get requests => _requests;
  List<res.FriendRes> get connections => _connections;

  // loads connection request received
  void loadConnectionRequests(String userId) {
    ConnectionService.getConnectionRequests(userId).then((value) {
      if (value != null) {
        _requests = value;
        notifyListeners();
      }
    });
  }

  // loads connections that have already been made
  void loadConnections(String userId) {
    ConnectionService.getConnections(userId).then((value) {
      if (value != null) {
        _connections = value;
        notifyListeners();
      }
    });
  }
}
