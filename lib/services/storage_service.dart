import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery or camera.
  static Future<XFile?> pickImage({
    BuildContext? context,
    ImageSource source = ImageSource.gallery,
  }) async {
    ImageSource? selectedSource;

    if (context != null) {
      selectedSource = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select Image Source',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Camera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
      if (selectedSource == null) return null;
    } else {
      selectedSource = source;
    }

    try {
      return await _picker.pickImage(
        source: selectedSource,
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
    // 1. Validate format
    final pathLower = file.path.toLowerCase();
    final nameLower = file.name.toLowerCase();
    final hasValidExt = ['jpg', 'jpeg', 'png', 'webp'].any((ext) => pathLower.endsWith('.$ext') || nameLower.endsWith('.$ext'));
    if (!hasValidExt) {
      final ext = file.path.split('.').last.toLowerCase();
      throw Exception('Unsupported format (.$ext). Only JPG, JPEG, PNG, and WEBP are supported.');
    }

    // 2. Validate size
    final sizeInBytes = await file.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      final sizeInMb = (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);
      throw Exception('Image size exceeds 5MB limit (current size: $sizeInMb MB).');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to upload images.');
    }

    try {
      final ref = _storage.ref().child(bucketPath);
      final contentType = _contentTypeForPath(file.path);
      final metadata = SettableMetadata(contentType: contentType);

      // Read as bytes to bypass Android Scoped Storage/URI permission issues
      final bytes = await file.readAsBytes();
      await ref.putData(bytes, metadata);

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('[StorageService] Firebase upload failed: ${e.code} ${e.message}');
      throw Exception(e.message ?? e.code);
    } catch (e) {
      debugPrint('[StorageService] Upload failed: $e');
      throw Exception(e.toString());
    }
  }
}
