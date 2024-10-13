import 'package:flutter/material.dart';
import 'package:mvp_one/services/rest/post_services/playground_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class PlaygroundPostsLoad extends ChangeNotifier {
  // posts to load by others users
  List<payload.PlaygroundPost> _posts = [];

  // used for pagination, lazy loading
  String? _lastPostId;

  // Variable to check if there are more posts to show in square
  bool? _hasMorePosts;

  // Public getters
  List<payload.PlaygroundPost> get posts => _posts;
  bool? get hasMorePosts => _hasMorePosts ?? false;

  Future<List<payload.PlaygroundPost>?> loadPartialPosts(
      {required bool isFromScratch}) async {
    payload.PlaygroundPostsRes? playgroundPostsRes;
    if (isFromScratch) {
      _lastPostId = null;
      _posts = [];
    }

    playgroundPostsRes =
        await PlaygroundPostService().getPartialPosts(_lastPostId);
    if (playgroundPostsRes != null) {
      _lastPostId = playgroundPostsRes.lastPostId;
      _posts += playgroundPostsRes.posts!;
      notifyListeners();
      return posts;
    }
    return null;
  }
}
