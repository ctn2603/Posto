import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/other_square_posts_load.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/user_square_posts_load.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/post_services/square_post.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:provider/provider.dart';

// User Post Status Notifier
class CreateSquarePost extends ChangeNotifier {
  bool _isPosting = false;

  bool get isPosting => _isPosting;

  set isPosting(bool value) {
    _isPosting = value;
    notifyListeners();
  }

  Future<bool> createPost({required String filePath}) async {
    isPosting = true;
    try {
      XFile disImg = XFile(filePath);

      CredentialStorageService().getUserId().then((userId) async {
        // Upload resource & submit post
        await SquarePostService().addPost(userId, "", disImg);

        // Get username
        final username = await CredentialStorageService().getUsername();

        // Load posts
        await Future.wait([
          Provider.of<OtherSquarePostsLoad>(
            Global.getSquareContext(),
            listen: false,
          ).loadPartialPosts(isFromScratch: true, userName: username!),
          Provider.of<UserSquarePostsLoad>(
            Global.getSquareContext(),
            listen: false,
          ).loadUserSquarePosts(userId: userId),
        ]);

        isPosting = false;
      }).catchError((error) {
        isPosting = false;
      });
      return true;
    } catch (error) {
      await showErrorDialog(error.toString());
      isPosting = false;
    }
    return false;
  }
}
