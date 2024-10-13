import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvp_one/flavors.dart';
import 'package:mvp_one/screens/signin/terms_and_conditions.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/image_upload.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';

class CreateProfilePic extends StatefulWidget {
  final Future<void> Function()? _signUpCallback;
  final bool _signUp;

  const CreateProfilePic(
      {Key? key, Future<void> Function()? signUpCallback, required bool signUp})
      : _signUpCallback = signUpCallback,
        _signUp = signUp,
        super(key: key);

  @override
  State<CreateProfilePic> createState() => _CreateProfilePicState();
}

class _CreateProfilePicState extends State<CreateProfilePic> {
  late bool _signUp;
  final picker = ImagePicker();
  CameraController? controller; //controller for camera
  XFile? disImg; //for captured image

  @override
  void initState() {
    super.initState();

    _signUp = widget._signUp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 145),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.zero, // Set padding to zero
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Image.asset("assets/icons/sign_in_back.png"),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text("Profile picture:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          const SizedBox(height: 5),
          const Text(
            "The real life lover one ;)",
            style:
                TextStyle(color: Color.fromRGBO(0, 0, 0, 0.50), fontSize: 12),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              _showPhotoSelectionDialog();
            },
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: const Color.fromRGBO(
                          255, 58, 11, 1.0), // Set the color of the border
                      width: 4.0, // Set the width of the border
                    )),
                child: disImg != null
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image.file(
                          File(disImg!.path),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ))
                    : const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: ImageIcon(
                          AssetImage("assets/icons/add_profile_picture.png"),
                          color: Color.fromRGBO(255, 58, 11, 1.0),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
              child: SizedBox(
                  width: 190,
                  height: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: const Color(0xFFF04914),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: disImg != null
                        ? () async {
                            CredentialStorageService credentialStorage =
                                CredentialStorageService();
                            String? userId =
                                await credentialStorage.getUserId();
                            bool? userExists =
                                await UserService.userExists(userId);

                            if (_signUp && !userExists!) {
                              await widget._signUpCallback!();
                              await updateImage();
                            } else if (_signUp && userExists!) {
                              Navigator.of(context).push(
                                StaticPageRoute(
                                  child: const TermsAndConditions(),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                              updateImage();
                            }
                          }
                        : null,
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ))),
        ],
      ),
    ));
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
        disImg = XFile(croppedImage!.path);
      });
    } else {
      print('image is not valid');
    }
  }

  Future<void> updateImage() async {
    CredentialStorageService credentialStorage = CredentialStorageService();
    String oldImageUrl =
        await UserService.getProfileImage(await credentialStorage.getEmail());

    String? imageUrl;
    if (oldImageUrl.isEmpty) {
      imageUrl = await ImageUploadService()
          .upload(folder: F.profileImagesStorage, image: disImg!);
    } else {
      imageUrl = await ImageUploadService().upload(
          folder: F.profileImagesStorage,
          image: disImg!,
          oldImageUrl: oldImageUrl);
    }

    String userId = await credentialStorage.getUserId();
    await credentialStorage.setUserProfileImage(imageUrl!);
    await UserService.updateProfileImage(userId, imageUrl);
  }
}
