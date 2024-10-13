import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvp_one/providers/load_profile_picture.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/image_upload.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:provider/provider.dart';

class EditPfp extends StatefulWidget {
  final String _profileImage;
  const EditPfp({Key? key, required String profileImage})
      : _profileImage = profileImage,
        super(key: key);

  @override
  State<EditPfp> createState() => _EditPfpState();
}

class _EditPfpState extends State<EditPfp> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  String? _name;
  String? _username;
  final picker = ImagePicker();
  CameraController? controller; //controller for camera
  XFile? _disImg;
  String? _profileImage;
  bool _updating = false;

  @override
  initState() {
    super.initState();
    _profileImage = widget._profileImage;
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    init();
  }

  Future<void> init() async {
    String? name = await CredentialStorageService().getName();
    String? username = await CredentialStorageService().getUsername();
    if (name != null) {
      _nameController.text = name;
    }

    if (username != null) {
      _usernameController.text = username;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const DefaultTextStyle(
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    fontFamily: "IBMPlexSans"),
                child: Text("Complete your profile")),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                _showPhotoSelectionDialog();
              },
              child: Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: _disImg != null
                          ? Image.file(
                              File(_disImg!.path),
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                            )
                          : Image.network(
                              _profileImage!,
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                            )),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "EDIT PROFILE PICTURE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "IBMPlexSans",
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 270),
              child: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
                child: const Text('Name'),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            SizedBox(
              width: 330,
              child: TextField(
                controller: _nameController,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(240, 73, 20, 1.0),
                      width: 4.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(240, 73, 20, 1.0),
                      width: 4.0,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.only(top: 13, bottom: 13, left: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 230),
              child: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
                child: const Text('Username'),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            SizedBox(
              width: 330,
              child: TextField(
                controller: _usernameController,
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(240, 73, 20, 1.0),
                        width: 4.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(240, 73, 20, 1.0),
                        width: 4.0,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.only(top: 13, bottom: 13, left: 10)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 0, left: 110, right: 110),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Material(
                  color: const Color.fromRGBO(240, 73, 20, 1.0),
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    onTap: _updating
                        ? null
                        : () async {
                            setState(() {
                              _updating = true;
                            });
                            if (await updateImage() == true &&
                                await updateName() == true &&
                                await updateUsername() == true) {
                              if (context.mounted) {
                                setState(() {
                                  _updating = false;
                                });
                                Navigator.of(context).pop();
                              }
                            } else {
                              setState(() {
                                _updating = false;
                              });
                            }
                          },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      alignment: Alignment.center,
                      child: _updating
                          ? const Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator()))
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "IBMPlexSans",
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5), // Add some space between buttons
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "NOT NOW",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "IBMPlexSans",
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPhotoSelectionDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          actions: <Widget>[
            CupertinoDialogAction(
              child: const SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Take a Photo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    SizedBox(width: 100),
                    ImageIcon(AssetImage("assets/icons/camera.png"), size: 30)
                  ],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
                _imgFromPhone(true);
              },
            ),
            CupertinoDialogAction(
              child: const SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Choose from Gallery',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    SizedBox(width: 43),
                    ImageIcon(AssetImage("assets/icons/gallery.png"), size: 25)
                  ],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
                _imgFromPhone(false);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _imgFromPhone(bool camera) async {
    XFile? pickedImage;
    if (camera) {
      pickedImage = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedImage = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedImage != null) {
      debugPrint('image is valid');
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.rectangle,
        compressQuality: 95,
      );

      setState(() {
        _disImg = XFile(croppedImage!.path);
      });
    } else {
      print('image is not valid');
    }
  }

  Future<bool> updateImage() async {
    if (_disImg != null) {
      CredentialStorageService credentialStorage = CredentialStorageService();
      String oldImageUrl =
          await UserService.getProfileImage(await credentialStorage.getEmail());
      String? imageUrl = await ImageUploadService().upload(
          folder: "profile_images", image: _disImg!, oldImageUrl: oldImageUrl);
      String userId = await credentialStorage.getUserId();
      await credentialStorage.setUserProfileImage(imageUrl!);
      await UserService.updateProfileImage(userId, imageUrl);
      Provider.of<ProfilePicLoad>(Global.getSCPTabContext(), listen: false)
          .loadProfilePic();
    }
    return true;
  }

  Future<bool> updateName() async {
    if (_name != null && _name != "") {
      CredentialStorageService credentialStorage = CredentialStorageService();

      String userId = await credentialStorage.getUserId();
      await credentialStorage.setName(_name!);
      await UserService.updateName(userId, _name!);
      Provider.of<ProfilePicLoad>(Global.getSCPTabContext(), listen: false)
          .loadProfilePic();
    }
    return true;
  }

  Future<bool> updateUsername() async {
    if (_username != null && _username != "") {
      CredentialStorageService credentialStorage = CredentialStorageService();

      String userId = await credentialStorage.getUserId();
      if (await UserService.updateUsername(userId, _username!)) {
        await credentialStorage.setUsername(_username!);
        Provider.of<ProfilePicLoad>(Global.getSCPTabContext(), listen: false)
            .loadProfilePic();
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}
