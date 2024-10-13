import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mvp_one/configs/app_uri.dart';
import 'package:mvp_one/services/rest/post_services/post.service.dart';
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class CampusPostService extends PostService {
  @override
  String getAddLikeUri() {
    return addCampusLikeUri;
  }

  @override
  String getRemoveLikeUri() {
    return removeCampusLikeUri;
  }

  @override
  String getUsersLikedUri() {
    return getCampusUsersLikedUri;
  }

  String getPostArticleUri() {
    return getCampusPostArticleUri;
  }

  Future<String?> getArticleLink(String postId) async {
    http.Response? response = await RestService.get(
        getPostArticleUri().replaceAll("{postid}", postId));
    if (response != null) {
      dynamic data = json.decode(response.body);
      return data['url'];
    } else {
      return null;
    }
  }

  Future<payload.CampusPostsRes?> getPartialPosts(String? lastPostId) async {
    http.Response? response;
    if (lastPostId == null) {
      response = await RestService.get(getPartialCampusPostsUri);
    } else {
      response = await RestService.get(getPartialCampusPostsWithIdUri
          .replaceAll("{last-post-id}", lastPostId));
    }

    if (response != null) {
      dynamic data = json.decode(response.body);
      return payload.CampusPostsRes.fromJson(data);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }
}
