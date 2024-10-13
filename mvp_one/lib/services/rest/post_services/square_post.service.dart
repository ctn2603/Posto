import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mvp_one/configs/app_uri.dart';
import 'package:mvp_one/flavors.dart';
import 'package:mvp_one/services/rest/image_upload.service.dart';
import 'package:mvp_one/services/rest/post_services/post.service.dart';
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/request/create_post_req.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class SquarePostService extends PostService {
  @override
  String getAddLikeUri() {
    return addSquareLikeUri;
  }

  @override
  String getRemoveLikeUri() {
    return removeSquareLikeUri;
  }

  @override
  String getUsersLikedUri() {
    return getSquareUsersLikedUri;
  }

  Future<payload.SquarePostsRes?> getPartialPosts(String? lastPostId) async {
    http.Response? response;
    if (lastPostId == null) {
      response = await RestService.get(getPartialSquarePostsWithTimezoneUri);
    } else {
      response = await RestService.get(getPartialSquarePostsWithTimezoneUri
          .replaceAll("{last-post-id}", lastPostId));
    }

    if (response != null) {
      dynamic data = json.decode(response.body);
      return payload.SquarePostsRes.fromJson(data);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  Future<void> addPost(String userId, String caption, XFile image) async {
    String? imageUrl = await ImageUploadService()
        .upload(folder: F.postImagesStorage, image: image);
    if (imageUrl != null) {
      http.Response? response = await RestService.post(
          createSquarePostUri,
          CreatePostRequestPayload(
            userId: userId,
            imageUrl: imageUrl,
            caption: caption,
          ));
      if (response?.statusCode != 200) {
        await showErrorDialog(jsonDecode(response!.body)["message"]);
      }
    }
  }

  // Used for retrieving the posts in sqaure feed
  Future<payload.SquarePostsNotByUserRes?> getPartialPostsNotByUser(
      String? time, String? lastPostId, String? userName) async {
    http.Response? response;
    if (lastPostId == null) {
      response = await RestService.get(getPartialSquarePostsNotByUserUri
          .replaceAll("{time}", time!)
          .replaceAll("{username}", userName!));
    } else {
      response = await RestService.get(
          getPartialSquarePostsNotByUserWithLastPostIdUri
              .replaceAll("{time}", time!)
              .replaceAll("{username}", userName!)
              .replaceAll("{last-post-id}", lastPostId));
    }

    if (response != null) {
      dynamic data = json.decode(response.body);
      return payload.SquarePostsNotByUserRes.fromJson(data);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  Future<payload.SquarePostsRes?> getPartialPostswithTime(
      String time, String? lastPostId) async {
    http.Response? response;
    if (lastPostId == null) {
      response = await RestService.get(
          getPartialSquarePostsWithTimezoneUri.replaceAll("{timezone}", time));
    } else {
      response = await RestService.get(getPartialSquarePostsWithTimezoneandIDUri
          .replaceAll("{timezone}", time)
          .replaceAll("{last-post-id}", lastPostId));
    }

    if (response != null) {
      dynamic data = json.decode(response.body);
      return payload.SquarePostsRes.fromJson(data);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  Future<List<payload.SquarePost>?> getPostsFromUserId(String? userId) async {
    http.Response? response = await RestService.get(
        getSquarePostsFromUserIdUri.replaceAll("{userid}", userId!));

    if (response != null) {
      dynamic data = json.decode(response.body);

      List<payload.SquarePost> posts = [];
      if (data['posts'] != null) {
        for (dynamic post in data['posts']) {
          posts.add(payload.SquarePost.fromJson(post));
        }
      }

      return posts;
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return [];
    }
  }
}
