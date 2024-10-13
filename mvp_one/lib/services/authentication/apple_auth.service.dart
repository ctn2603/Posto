import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvp_one/models/user_model.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/services/authentication/base_auth.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService extends BaseAuthService {
  @override
  Future<UserModel?> signIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(oauthCredential);
      return UserModel.fromUserCredential(userCredential: userCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // Do nothing here, not an error. The user just doesn't want to
        // sign in with apple
      } else {
        print('Apple Sign-In Authorization Error: ${e.code}');
        // Handle other error scenarios if needed
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(Global.getGlobalContext()).showSnackBar(
          _customSnackBar(
            content: 'The account already exists with a different credential.',
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
          content: 'Error occurred using Apple Sign-In. Try again.',
        ),
      );
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

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
