import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery or camera.
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
    } catch (e) {
      debugPrint('[StorageService] Error picking image: $e');
      rethrow;
    }
  }

  /// Builds a user-scoped storage path: users/{uid}/{folder}/{fileName}
  static String userScopedPath({
    required String uid,
    required String folder,
    required String fileName,
  }) {
    return 'users/$uid/$folder/$fileName';
  }

  static String _contentTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Uploads picked image to Firebase Storage and returns the download URL.
  static Future<String> uploadImage({
    required XFile file,
    required String bucketPath,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to upload images.');
    }

    try {
      final ref = _storage.ref().child(bucketPath);
      final contentType = _contentTypeForPath(file.path);
      final metadata = SettableMetadata(contentType: contentType);

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await ref.putData(bytes, metadata);
      } else {
        await ref.putFile(File(file.path), metadata);
      }

      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('[StorageService] Firebase upload failed: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[StorageService] Upload failed: $e');
      rethrow;
    }
  }
}
