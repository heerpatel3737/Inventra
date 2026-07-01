import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _picker = ImagePicker();

  /// Picks an image from gallery.
  static Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
    } catch (e) {
      debugPrint('[StorageService] Error picking image: $e');
      return null;
    }
  }

  /// Uploads picked image to Firebase Storage and returns the download URL.
  static Future<String> uploadImage({
    required XFile file,
    required String bucketPath,
  }) async {
    final ref = _storage.ref().child(bucketPath);
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      await ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }
    return await ref.getDownloadURL();
  }
}
