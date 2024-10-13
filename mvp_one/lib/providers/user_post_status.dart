import 'package:flutter/material.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/user_square_posts_load.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:provider/provider.dart';

// User Post Status Notifier
class UserPostStatus extends ChangeNotifier {
  bool? _hasUserPosted;

  // public getters
  bool? get hasUserPosted => _hasUserPosted;

  Future<bool> checkUserPostStatus() async {
    // Load the provider or the ChangeNotifier
    final provider = Provider.of<UserSquarePostsLoad>(
      Global.getSquareContext(),
      listen: false,
    );
    _hasUserPosted = provider.posts.isNotEmpty;
    notifyListeners();
    return _hasUserPosted!;
  }
}
