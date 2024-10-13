import 'dart:convert';
import 'dart:io' show Platform; //at the top

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mvp_one/configs/app_uri.dart';
import 'package:mvp_one/flavors.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/rest.service.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:mvp_one/utils/payloads/request/metadata_req.dart';
import 'package:mvp_one/utils/payloads/request/sign_in_req.dart';
import 'package:mvp_one/utils/payloads/request/sign_up_req.dart';
import 'package:mvp_one/utils/payloads/request/update_profile_img_req.dart';
import 'package:mvp_one/utils/payloads/request/update_user_name_req.dart';
import 'package:mvp_one/utils/payloads/response/sign_in_res.dart';
import 'package:mvp_one/utils/payloads/response/sign_up_res.dart' as payload;
import 'package:mvp_one/utils/payloads/response/user.dart';
import 'package:mvp_one/utils/payloads/response/users_res.dart';

class UserService {
  static Future<void> acknowledgedSquare(String userId) async {
    http.Response? response = await RestService.patch(
        setAcknowledgedSquareUri, AcknowledgeSquareReq(userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<bool?> hasAcknowledgedSquare(String userId) async {
    http.Response? response = await RestService.get(
        checkAcknowledgedSquareUri.replaceAll("{userid}", userId));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["acknowledgeSquare"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }
  
  static Future<void> acknowledgedTermsAndConditions(String userId) async {
    http.Response? response = await RestService.patch(
        setAcknowledgedTermsAndConditionsUri, AcknowledgeTermsAndConditionsReq(userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<bool?> hasAcknowledgedTermsAndConditions(String userId) async {
    http.Response? response = await RestService.get(
        checkAcknowledgedTermsAndConditionsUri.replaceAll("{userid}", userId));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["acknowledge_terms_and_conditions"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<void> acknowledgedPlayground(String userId) async {
    http.Response? response = await RestService.patch(
        setAcknowledgedPlaygroundUri, AcknowledgePlaygroundReq(userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<bool?> hasAcknowledgedPlayground(String userId) async {
    http.Response? response = await RestService.get(
        checkAcknowledgedPlaygroundUri.replaceAll("{userid}", userId));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["acknowledgePlayground"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<void> acknowledgedCampus(String userId) async {
    http.Response? response = await RestService.patch(
        setAcknowledgedCampusUri, AcknowledgeCampusReq(userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<bool?> hasAcknowledgedCampus(String userId) async {
    http.Response? response = await RestService.get(
        checkAcknowledgedCampusUri.replaceAll("{userid}", userId));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["acknowledgeCampus"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<bool?> isOnboard(String userId) async {
    http.Response? response =
        await RestService.get(checkOnboardUri.replaceAll("{userid}", userId));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["isOnboard"];
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<void> onboarded(String userId) async {
    http.Response? response =
        await RestService.patch(setOnboardUri, OnboardReq(userId: userId));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<SignInRes?> signin(String username, String? password) async {
    http.Response? response = await RestService.post(
        signinUri, SignInReq(username: username, password: password));

    if (response?.statusCode == 200) {
      SignInRes payload = SignInRes.fromJson(jsonDecode(response!.body));

      await saveUserInfo(username, payload.name!, payload.userId!,
          payload.email!, payload.profileImage!);
      return payload;
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<payload.SignUpRes?> signup(
      String name,
      String username,
      String? password,
      String? phone,
      String email,
      String? profileImage,
      String userId) async {
    http.Response? response = await RestService.post(
        signupUri,
        SignUpReq(
          name: name,
          username: username,
          password: password ?? ' ',
          email: email,
          phone: phone ?? ' ',
          profileImage: profileImage ?? '',
          userId: userId,
        ));
    if (response?.statusCode == 200) {
      payload.SignUpRes signUpPayload =
          payload.SignUpRes.fromJson(jsonDecode(response!.body));
      await saveUserInfo(username, signUpPayload.name!, signUpPayload.userId!,
          signUpPayload.email!, signUpPayload.profileImage!);
      return signUpPayload;
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  // Save user info after login or signup
  static Future<void> saveUserInfo(String username, String name, String userId,
      String email, String profileImage) async {
    CredentialStorageService credentialStorage = CredentialStorageService();
    await credentialStorage.setUsername(username);
    await credentialStorage.setName(name);
    await credentialStorage.setUserId(userId);
    await credentialStorage.setEmail(email);
    await credentialStorage.setUserProfileImage(profileImage);

    // Save firebase messaging token
    await UserService._saveFcmToken();
  }

  static Future<void> deleteUserInfo() async {
    await UserService._deleteFcmToken();

    CredentialStorageService credentialStorage = CredentialStorageService();
    await credentialStorage.deleteFcmToken();
    await credentialStorage.deleteUsername();
    await credentialStorage.deleteUserId();
    await credentialStorage.deleteEmail();
    await credentialStorage.deleteName();
    await credentialStorage.deleteUserProfileImage();
  }

  // This function directly modify the database without interacting with the server,
  // this helps reduce the workload for the server
  static Future<void> _saveFcmToken() async {
    // Get device fcm token
    String? deviceFcmToken = await FirebaseMessaging.instance.getToken();

    // Add token and platform to fcm_tokens subcollection
    String userId = await CredentialStorageService().getUserId();
    DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection(F.usersDb).doc(userId);
    CollectionReference tokenCollectionRef = userDoc.collection('fcm_tokens');
    tokenCollectionRef
        .add({'token': deviceFcmToken, 'platform': Platform.operatingSystem});
    await CredentialStorageService().setFcmToken(deviceFcmToken!);
  }

  // This function directly modify the database without interacting with the server,
  // this helps reduce the workload for the server
  static Future<void> _deleteFcmToken() async {
    // Get stored fcm token
    String? storedFcmToken = await CredentialStorageService().getFcmToken();

    if (storedFcmToken != null) {
      // Find documents of which tokens match the stored token
      String userId = await CredentialStorageService().getUserId();
      DocumentReference<Map<String, dynamic>> userDoc =
          FirebaseFirestore.instance.collection(F.usersDb).doc(userId);
      CollectionReference tokenCollectionRef = userDoc.collection('fcm_tokens');
      QuerySnapshot querySnapshot = await tokenCollectionRef
          .where('token', isEqualTo: storedFcmToken)
          .get();

      // Delete documents that match
      try {
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          DocumentReference documentRef = documentSnapshot.reference;
          await documentRef.delete();
        }
      } catch (error) {
        await showErrorDialog(error.toString());
      }
    }
  }

  static Future<payload.SignUpRes?> getUserByIdLogin(String id) async {
    final http.Response? response =
        await RestService.get(getUserByIdUri.replaceAll("{userid}", id));

    if (response?.statusCode == 200) {
      dynamic data = jsonDecode(response!.body);
      return payload.SignUpRes.fromJson(data["user"]);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<User?> getUserById(String id) async {
    final http.Response? response =
        await RestService.get(getUserByIdUri.replaceAll("{userid}", id));

    if (response?.statusCode == 200) {
      dynamic data = jsonDecode(response!.body);
      return User.fromJson(data["user"]);
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return null;
    }
  }

  static Future<bool?> userExists(String? id) async {
    if (id == null) {
      return false;
    }

    final http.Response? response =
        await RestService.get(getUserByIdUri.replaceAll("{userid}", id));
    if (response?.statusCode == 200) {
      final dynamic user = jsonDecode(response!.body)["user"];
      return user["email"] != null;
    } else {
      return false;
    }
  }

  static Future<bool?> usernameExists(String username) async {
    final http.Response? response = await RestService.get(
        checkUsernameExistsUri.replaceAll("{username}", username));
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body)["user_exists"];
    } else {
      return false;
    }
  }

  static Future<void> updateProfileImage(String userId, String imgUrl) async {
    http.Response? response = await RestService.put(
        profileImageUpdateUri + userId, UpdateProfileImageReq(imgUrl: imgUrl));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<void> updateName(String userId, String name) async {
    http.Response? response = await RestService.put(
        nameUpdateUri + userId, UpdateNameReq(name: name));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
  }

  static Future<bool> updateUsername(String userId, String username) async {
    http.Response? response = await RestService.put(
        userNameUpdateUri + userId, UpdateUserNameReq(username: username));
    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return false;
    }
    return true;
  }

  static Future<String> getProfileImage(String? email) async {
    final String uri = getProfileImgWithEmailUri + email!;
    final http.Response? response = await RestService.get(uri);
    if (response?.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response!.body);
      final dynamic user = data['user'];
      return user;
    }
    return '';
  }

  static Future<void> saveNotificationsStatus(bool read) async {
    try {
      String userId = await CredentialStorageService().getUserId();
      DocumentReference<Map<String, dynamic>> userDoc =
          FirebaseFirestore.instance.collection(F.usersDb).doc(userId);
      userDoc.update({'metadata.readNotifications': read});
    } on Exception catch (error) {
      await showErrorDialog(error.toString());
    }
  }

  static Future<bool> doesReadNotifications() async {
    try {
      String userId = await CredentialStorageService().getUserId();
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection(F.usersDb)
          .doc(userId)
          .get();

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('metadata') &&
          userData['metadata'].containsKey("readNotifications")) {
        bool? read = userSnapshot.get('metadata.readNotifications');
        if (read != null) {
          return read;
        }
      }
      return false;
    } on Exception catch (error) {
      await showErrorDialog(error.toString());
      return false;
    }
  }

  static Future<Users> getAllUsers(String? email) async {
    final http.Response? response = await RestService.get(getAllUsersUri);
    if (response?.statusCode == 200) {
      return Users.fromJson(jsonDecode(response!.body));
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
    return const Users(users: []);
  }

  static Future<Users> getUsersBySearch(String input) async {
    final String userId = await CredentialStorageService().getUserId();
    final response = await RestService.get(getUsersBySearchUri
        .replaceAll("{userid}", userId)
        .replaceAll("{pattern}", input));

    if (response?.statusCode == 200) {
      return Users.fromJson(jsonDecode(response!.body));
    } else {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
    }
    return const Users(users: []);
  }

  static Future<bool> deleteUserAccount() async {
    final String userId = await CredentialStorageService().getUserId();
    final response = await RestService.get(
        deleteUserAccountUri.replaceAll("{userid}", userId));

    if (response?.statusCode != 200) {
      await showErrorDialog(jsonDecode(response!.body)["message"]);
      return false;
    }
    return true;
  }
}
