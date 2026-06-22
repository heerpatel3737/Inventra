import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../repositories/auth_repository.dart';

/// Provider for raw [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

/// StreamProvider tracking the current [User] authentication state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// StateProvider tracking UI loading state during auth processes.
final authLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
