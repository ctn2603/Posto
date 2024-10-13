import 'package:mvp_one/utils/payloads/response/base_res.dart';

class FriendRequestsReceivedRes extends BaseRes {
  String? name;
  String? username;
  String? profileImage;
  String? senderId;
  String? friendshipStatus;

  FriendRequestsReceivedRes(
      {required this.name,
      required this.username,
      required this.profileImage,
      required this.senderId,
      required this.friendshipStatus});

  factory FriendRequestsReceivedRes.fromJson(Map<String, dynamic> json) {
    return FriendRequestsReceivedRes(
        name: json["name"],
        username: json['username'],
        profileImage: json['profileImage'],
        senderId: json['sender_id'],
        friendshipStatus: json['friendship_status']);
  }
}

class FriendRes extends BaseRes {
  String? name;
  String? username;
  String? profileImage;
  String? id;
  String? friendshipStatus;

  FriendRes(
      {required this.name,
      required this.username,
      required this.profileImage,
      required this.id,
      required this.friendshipStatus});

  factory FriendRes.fromJson(Map<String, dynamic> json) {
    return FriendRes(
        name: json["name"],
        username: json['username'],
        profileImage: json['profileImage'],
        id: json['id'],
        friendshipStatus: json['friendship_status']);
  }
}
