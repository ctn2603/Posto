import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mvp_one/configs/app_uri.dart';
import 'package:mvp_one/services/rest/post_services/post.service.dart';
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class PlaygroundPostService extends PostService {
  @override
  String getAddLikeUri() {
    return addPlaygroundLikeUri;
  }

  @override
  String getRemoveLikeUri() {
    return removePlaygroundLikeUri;
  }

  @override
  String getUsersLikedUri() {
    return getPlaygroundUsersLikedUri;
  }

  Future<payload.PlaygroundPostsRes?> getPartialPosts(
      String? lastPostId) async {
    http.Response? response;
    if (lastPostId == null) {
      response = await RestService.get(getPartialPlaygroundPostsUri);
    } else {
      response = await RestService.get(getPartialPlaygroundPostsWithIdUri
          .replaceAll("{last-post-id}", lastPostId));
    }

    if (response != null) {
      dynamic data = json.decode(response.body);
      return payload.PlaygroundPostsRes.fromJson(data);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }
}
