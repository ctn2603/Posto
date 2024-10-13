import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// This class stores credential online in an encrypted format
class CredentialStorageService {
  FlutterSecureStorage? _storage;
  static final CredentialStorageService _instance =
      CredentialStorageService._();

  CredentialStorageService._() {
    _storage = const FlutterSecureStorage();
  }

  factory CredentialStorageService() {
    return _instance;
  }

  Future setUsername(String username) async {
    await _storage!.write(key: 'username', value: username);
  }

  Future<String?> getUsername() async {
    return _storage!.read(key: 'username');
  }

  Future deleteUsername() async {
    await _storage!.delete(key: 'username');
  }

  Future setName(String name) async {
    await _storage!.write(key: 'name', value: name);
  }

  Future<String?> getName() async {
    return _storage!.read(key: 'name');
  }

  Future deleteName() async {
    await _storage!.delete(key: 'name');
  }

  Future setUserId(String userId) async {
    await _storage!.write(key: 'userId', value: userId);
  }

  Future getUserId() async {
    return _storage!.read(key: 'userId');
  }

  Future deleteUserId() async {
    await _storage!.delete(key: 'userId');
  }

  Future setUserProfileImage(String profileImage) async {
    await _storage!.write(key: 'profileImage', value: profileImage);
  }

  Future<String?> getUserProfileImage() async {
    return _storage!.read(key: 'profileImage');
  }

  Future deleteUserProfileImage() async {
    await _storage!.delete(key: 'profileImage');
  }

  Future setPassword(String password) async {
    await _storage!.write(key: 'password', value: password);
  }

  Future getPassword() async {
    return _storage!.read(key: 'password');
  }

  Future deletePassword() async {
    await _storage!.delete(key: 'password');
  }

  Future setEmail(String email) async {
    await _storage!.write(key: 'email', value: email);
  }

  Future getEmail() async {
    return _storage!.read(key: 'email');
  }

  Future deleteEmail() async {
    await _storage!.delete(key: 'email');
  }

  // Set firebase messaging token
  Future setFcmToken(String token) async {
    await _storage!.write(key: 'fcm_token', value: token);
  }

  // Get firebase messaging token
  Future<String?> getFcmToken() async {
    return _storage!.read(key: 'fcm_token');
  }

  Future deleteFcmToken() async {
    await _storage!.delete(key: 'fcm_token');
  }
}
