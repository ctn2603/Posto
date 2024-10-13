import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:mvp_one/utils/dialogs/error_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class ImageUploadService {
  Future<String?> upload(
      {required String folder,
      required XFile image,
      String? oldImageUrl}) async {
    try {
      // Delete old image if exist
      if (oldImageUrl != null && await _isImageInStorage(oldImageUrl, folder)) {
        await _deleteImage(oldImageUrl);
      }

      return _pushImageToStorage(folder, image);
    } on Exception catch (error) {
      await showErrorDialog(error.toString());
      return null;
    }
  }

  Future<XFile?> _compressImage(XFile image) async {
    // Compress image (in order to load faster later in home screen)
    String targetPath = (await getTemporaryDirectory()).path;
    targetPath += image.path.split("/").last;
    XFile? compressedImage = (await FlutterImageCompress.compressAndGetFile(
        image.path, targetPath,
        quality: 40));
    return compressedImage;
  }

  Future<XFile?> _compressVideo(XFile image) async {
    MediaInfo? compressedVideo = (await VideoCompress.compressVideo(image.path,
        quality: VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true));
    return XFile(compressedVideo!.path!);
  }

  Future<void> _deleteImage(String imageUrl) async {
    FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  Future<bool> _isImageInStorage(String imageUrl, String folder) async {
    try {
      final reference = FirebaseStorage.instance.refFromURL(imageUrl);
      await reference.getDownloadURL();

      return true; // If no exception, the image exists in storage
    } catch (error) {
      // If the image does not exist or there's an error, catch the exception
      // and return false.

      return false;
    }
  }

  Future<String> _pushImageToStorage(String folder, XFile file) async {
    // Check the file is image or video
    final mime = lookupMimeType(file.path);
    XFile? compressedFile;

    if (mime!.startsWith('image/')) {
      compressedFile = await _compressImage(file);
    } else if (mime.startsWith('video/')) {
      compressedFile = await _compressVideo(file);
    }

    // Refer to the storage bucket in Firebase storage
    Reference storageBucket =
        FirebaseStorage.instance.ref().child("$folder/${file.name}");
    File? tmp = File(compressedFile!.path);

    // Push the image to firebase storage
    await storageBucket.putFile(tmp);
    String downloadUrl = await storageBucket.getDownloadURL();

    // Delete the temporary compressed image to save device's space
    await tmp.delete();
    return downloadUrl;
  }
}
