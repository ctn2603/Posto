import 'package:flutter/material.dart';
import 'package:mvp_one/services/credential_storage.service.dart';

class ProfilePicLoad extends ChangeNotifier {
  String _profilePic = "";

  // public getters
  String get profilePic => _profilePic;

  void loadProfilePic() {
    CredentialStorageService().getUserProfileImage().then((value) {
      if (value != null) {
        _profilePic = value;
        notifyListeners();
      }
    });
  }
}
