import 'package:flutter/material.dart';
import 'package:mvp_one/services/rest/post_services/campus_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class CampusPostsLoad extends ChangeNotifier {
  // posts to load by others users
  List<payload.CampusPost> _posts = [];

  // used for pagination, lazy loading
  String? _lastPostId;

  // Variable to check if there are more posts to show in square
  bool? _hasMorePosts;

  // Public getters
  List<payload.CampusPost> get posts => _posts;
  bool? get hasMorePosts => _hasMorePosts ?? false;

  Future<List<payload.CampusPost>?> loadPartialPosts(
      {required bool isFromScratch}) async {
    payload.CampusPostsRes? campusPostsRes;
    if (isFromScratch) {
      _lastPostId = null;
      _posts = [];
    }

    campusPostsRes = await CampusPostService().getPartialPosts(_lastPostId);
    if (campusPostsRes != null) {
      _lastPostId = campusPostsRes.lastPostId;
      _posts += campusPostsRes.posts!;
      notifyListeners();
      return posts;
    }
    return null;
  }
}
