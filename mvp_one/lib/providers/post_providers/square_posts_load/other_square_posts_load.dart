import 'package:flutter/material.dart';
import 'package:mvp_one/services/rest/post_services/square_post.service.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;

class OtherSquarePostsLoad extends ChangeNotifier {
  // posts to load by others users
  List<payload.SquarePost> _posts = [];

  // used for pagination, lazy loading
  String? _lastPostId;

  // checks if new batch of post has loaded or not
  bool _loaded = false;

  // user's timezone
  String? _time;

  // Variable to check if there are more posts to show in square
  bool? _hasMorePosts;

  // Public getters
  List<payload.SquarePost> get posts => _posts;
  bool get loaded => _loaded;
  bool? get hasMorePosts => _hasMorePosts;

  Future<List<payload.SquarePost>?> loadPartialPosts(
      {required bool isFromScratch, required String userName}) async {
    _loaded = false;
    notifyListeners();

    payload.SquarePostsNotByUserRes? squarePostsNotByUserRes;
    if (isFromScratch) {
      _lastPostId = null;
      _posts = [];
    }

    /// Only posts from 1 day ago. Even this is wrong but it can be refactored
    /// later when the architecture changes
    _time = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

    squarePostsNotByUserRes = await SquarePostService()
        .getPartialPostsNotByUser(_time, _lastPostId, userName);

    if (squarePostsNotByUserRes != null) {
      _lastPostId = squarePostsNotByUserRes.lastPostId;
      _posts += squarePostsNotByUserRes.posts!;
      _loaded = true;
      _hasMorePosts = squarePostsNotByUserRes.hasMorePosts;
      notifyListeners();
      return posts;
    }
    return null;
  }

  void filterAndUpdatePosts({
    List<payload.SquarePost>? posts,
  }) {
    final currentDate = DateTime.now();
    DateTime? creationDate;
    DateTime? expiryDate;
    posts ??= _posts;

    _posts = posts.where((element) {
      creationDate = element.createdAt;
      if (creationDate != null) {
        expiryDate = creationDate!.add(const Duration(days: 1));
        return currentDate.isBefore(expiryDate!);
      }
      return false;
    }).toList();

    notifyListeners();
  }
}
