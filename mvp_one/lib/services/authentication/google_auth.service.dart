import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvp_one/models/user_model.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/services/authentication/base_auth.service.dart';
import 'package:mvp_one/utils/global.dart';

class GoogleAuthService extends BaseAuthService {
  @override
  Future<UserModel?> signIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        return UserModel.fromUserCredential(userCredential: userCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(Global.getGlobalContext()).showSnackBar(
            _customSnackBar(
              content:
                  'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(Global.getGlobalContext()).showSnackBar(
            _customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(Global.getGlobalContext()).showSnackBar(
          _customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    }

    return null;
  }

  @override
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    // Delete user's session data (username, fcm token, user id, email, ....)
    await UserService.deleteUserInfo();
  }

  SnackBar _customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}
