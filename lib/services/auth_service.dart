// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   static const _defaultWebClientId =
//       '1095661697697-r8t6c9vildc8ag617tujgs870rh6c4ad.apps.googleusercontent.com';

//   // ── Lazy singleton ──────────────────────────────────────────────────────────
//   // FIX: was a getter — recreated a new GoogleSignIn instance on every access,
//   // so signIn() and signOut() operated on different objects, breaking sign-out
//   // and leaking state. Now initialised once on first use via late final.
//   late final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: const ['email'],
//     clientId: kIsWeb ? _webClientId : null,
//     serverClientId: kIsWeb ? null : _webClientId,
//   );

//   // ── Helpers ─────────────────────────────────────────────────────────────────
//   String get _webClientId =>
//       dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? _defaultWebClientId;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   User? get currentUser => _auth.currentUser;

//   // ── Persistence (web only) ──────────────────────────────────────────────────
//   Future<void> initializePersistence() async {
//     if (kIsWeb) {
//       await _auth.setPersistence(Persistence.LOCAL);
//     }
//   }

//   // ── Email / password ────────────────────────────────────────────────────────
//   Future<UserCredential> signInWithEmail(
//     String email,
//     String password,
//   ) async {
//     return _auth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   Future<UserCredential> signUpWithEmail(
//     String email,
//     String password,
//   ) async {
//     return _auth.createUserWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   // ── Google Sign-In ──────────────────────────────────────────────────────────
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // On web use the Firebase popup flow; on mobile use the native flow.
//       if (kIsWeb) {
//         final googleProvider = GoogleAuthProvider()
//           ..addScope('email')
//           ..setCustomParameters({'login_hint': 'user@example.com'});
//         return await _auth.signInWithPopup(googleProvider);
//       }

//       // Mobile: native Google Sign-In sheet.
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null; // user cancelled

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       debugPrint('[AuthService] Google Sign-In error: $e');
//       rethrow;
//     }
//   }

//   // ── Password reset ──────────────────────────────────────────────────────────
//   Future<void> sendPasswordResetEmail(String email) async {
//     await _auth.sendPasswordResetEmail(email: email.trim());
//   }

//   // ── Sign out ────────────────────────────────────────────────────────────────
//   Future<void> signOut() async {
//     // Disconnect (not just sign out) so the account picker shows next time.
//     if (!kIsWeb) {
//       try {
//         await _googleSignIn.disconnect();
//       } catch (_) {
//         // disconnect() throws if the user never signed in with Google — safe to ignore.
//       }
//     }

//     await _auth.signOut();
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _defaultWebClientId =
      '1095661697697-r8t6c9vildc8ag617tujgs870rh6c4ad.apps.googleusercontent.com';

  // ── Lazy singleton ──────────────────────────────────────────────────────────
  // FIX: was a getter — recreated a new GoogleSignIn instance on every access,
  // so signIn() and signOut() operated on different objects, breaking sign-out
  // and leaking state. Now initialised once on first use via late final.
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: kIsWeb ? null : _webClientId,
  );

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _webClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? _defaultWebClientId;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Persistence (web only) ──────────────────────────────────────────────────
  Future<void> initializePersistence() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  // ── Email / password ────────────────────────────────────────────────────────
  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // On web use the Firebase popup flow; on mobile use the native flow.
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'login_hint': 'user@example.com'});
        return await _auth.signInWithPopup(googleProvider);
      }

      // Mobile: native Google Sign-In sheet.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In error: $e');
      rethrow;
    }
  }

  // ── Password reset ──────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Sign out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    // Disconnect (not just sign out) so the account picker shows next time.
    if (!kIsWeb) {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        // disconnect() throws if the user never signed in with Google — safe to ignore.
      }
    }

    await _auth.signOut();
  }
}
