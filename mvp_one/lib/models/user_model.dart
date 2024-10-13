import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.profileImage,
    required this.userId,
  });

  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? username;
  final String? profileImage;
  final String? userId;

  factory UserModel.fromJson({required Map<String, dynamic> json}) {
    return UserModel(
      uid: json["id"] ?? '',
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      userId: json["id"],
      profileImage: json['profile_image'],
    );
  }

  factory UserModel.fromUserCredential(
      {required UserCredential userCredential}) {
    return UserModel(
      uid: userCredential.user!.uid,
      email: userCredential.user!.email ??
          userCredential.additionalUserInfo?.profile?['email'],
      phone: userCredential.user!.phoneNumber ??
          userCredential.additionalUserInfo?.profile?['phone'],
      username: null,
      profileImage: userCredential.user!.photoURL ??
          userCredential.additionalUserInfo?.profile?['picture'] ??
          ((userCredential.user?.providerData.isNotEmpty ?? false)
              ? userCredential.user?.providerData[0].photoURL
              : null),
      name: userCredential.user!.displayName ??
          userCredential.additionalUserInfo?.profile?['name'] ??
          userCredential.additionalUserInfo?.profile?['fullName'] ??
          ((userCredential.user?.providerData.isNotEmpty ?? false)
              ? userCredential.user?.providerData[0].displayName
              : null),
      userId: userCredential.user!.uid,
    );
  }
}
