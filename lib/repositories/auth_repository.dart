import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _authService.signInWithEmail(email, password);
    if (cred.user != null) {
      await _syncUserProfileToFirestore(cred.user!);
    }
    return cred;
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final cred = await _authService.signUpWithEmail(email, password);
    if (cred.user != null) {
      await _syncUserProfileToFirestore(cred.user!);
    }
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final cred = await _authService.signInWithGoogle();
    if (cred?.user != null) {
      await _syncUserProfileToFirestore(cred!.user!);
    }
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> _syncUserProfileToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': 'Admin', // Default role for CMS dashboard operations
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Offline fallback: allow login to proceed even if Firestore is not reachable
    }
  }
}
