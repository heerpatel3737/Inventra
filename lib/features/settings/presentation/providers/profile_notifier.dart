import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/user_profile_model.dart';
import '../../data/settings_repository.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfileModel>> {
  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  final SettingsRepository _repository;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      var profile = await _repository.fetchProfile();

      // If profile is empty, seed from Firebase Auth user data
      if (profile.name.isEmpty && profile.email.isEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Try to fetch role from Firestore
          String role = 'Staff';
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            if (doc.exists && doc.data()?['role'] != null) {
              role = doc.data()!['role'] as String;
            }
          } catch (_) {}

          profile = UserProfileModel(
            name: user.displayName ?? user.email?.split('@').first ?? 'User',
            email: user.email ?? '',
            role: role,
            phone: user.phoneNumber ?? '',
            department: 'General',
          );
          await _repository.updateProfile(profile);
        }
      }

      return profile;
    });
  }

  /// Persists profile update to SQLite, syncs to Firestore, and updates state.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String role,
    required String phone,
    required String department,
    String? photoUrl,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: name.trim(),
      email: email.trim(),
      role: role.trim(),
      phone: phone.trim(),
      department: department.trim(),
      photoUrl: photoUrl ?? current.photoUrl,
    );

    // Persist locally
    try {
      await _repository.updateProfile(updated);
    } catch (e) {
      debugPrint('[ProfileNotifier] Local save failed: $e');
    }

    // Sync to Firestore user doc
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'displayName': updated.name,
          'email': updated.email,
          'role': updated.role,
          'phone': updated.phone,
          'department': updated.department,
          'photoUrl': updated.photoUrl,
        }, SetOptions(merge: true));

        // Also update Firebase Auth display name
        if (user.displayName != updated.name) {
          await user.updateDisplayName(updated.name);
        }
      }
    } catch (e) {
      debugPrint('[ProfileNotifier] Firestore sync failed: $e');
    }

    state = AsyncValue.data(updated);
  }
}
