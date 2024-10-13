import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/request/like_req.dart';

abstract class PostService {
  String getAddLikeUri();
  String getUsersLikedUri();
  String getRemoveLikeUri();

  Future<void> addLike(String postId, String userId) async {
    http.Response? response = await RestService.patch(
        getAddLikeUri().replaceAll("{postid}", postId),
        LikeReq(postId: postId, userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  Future<List<dynamic>?> getUsersLiked(String postId) async {
    http.Response? response = await RestService.get(
        getUsersLikedUri().replaceAll("{postid}", postId));
    if (response != null) {
      dynamic data = json.decode(response.body);
      return data['usersLiked'];
    } else {
      return null;
    }
  }

  Future<void> removeLike(String postId, String userId) async {
    http.Response? response = await RestService.patch(
        getRemoveLikeUri().replaceAll("{postid}", postId),
        LikeReq(postId: postId, userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }
}
