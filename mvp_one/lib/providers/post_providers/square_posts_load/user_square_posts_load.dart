import 'package:flutter/material.dart';
import 'package:mvp_one/providers/user_post_status.dart';
import 'package:mvp_one/services/rest/post_services/square_post.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/payloads/response/post_res.dart' as payload;
import 'package:provider/provider.dart';

class UserSquarePostsLoad extends ChangeNotifier {
  // posts to load by current user
  List<payload.SquarePost> _posts = [];

  // checks if user's posts has loaded or not
  bool _loaded = false;

  // Public getters
  List<payload.SquarePost> get posts {
    return _posts;
  }

  bool get loaded => _loaded;

  // loads posts by the current user
  Future<void> loadUserSquarePosts({required String userId}) async {
    try {
      _loaded = false; // Before starting the fetch operation
      notifyListeners(); // Let listeners know we're about to fetch data

      List<payload.SquarePost>? value =
          await SquarePostService().getPostsFromUserId(userId);

      if (value != null) {
        filterAndUpdatePosts(posts: value);
      }

      _loaded = true;
      notifyListeners(); // Let listeners know fetch operation is done
      _updateUserPostStatus();
    } catch (error) {
      showErrorDialog("Error fetching posts: $error");

      // Depending on your app, you might want to set _loaded back to its original state or to another error state
      _loaded = false;
      notifyListeners();
    }
  }

  void _updateUserPostStatus() {
    final provider = Provider.of<UserPostStatus>(
      Global.getSquareContext(),
      listen: false,
    );
    provider.checkUserPostStatus();
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
    _updateUserPostStatus();
  }
}
