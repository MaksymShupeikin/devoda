import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Phone + OTP authentication via Supabase.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// Sends a one-time SMS code to [e164Phone] (e.g. `+380671234567`).
  Future<void> sendOtp(String e164Phone) async {
    await _client.auth.signInWithOtp(phone: e164Phone);
  }

  /// Verifies the [token] received over SMS for [e164Phone].
  Future<void> verifyOtp({
    required String e164Phone,
    required String token,
  }) async {
    await _client.auth.verifyOTP(
      phone: e164Phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

/// Emits whenever the Supabase auth state changes (sign in / out / refresh).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Whether a user is currently signed in (reactive).
final isSignedInProvider = Provider<bool>((ref) {
  final asyncAuth = ref.watch(authStateProvider);
  final session =
      asyncAuth.valueOrNull?.session ??
      ref.watch(authServiceProvider).currentSession;
  return session != null;
});

/// The signed-in user's phone (raw digits from Supabase, e.g. `380671234567`).
final currentUserPhoneProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider); // rebuild on auth changes
  return ref.watch(authServiceProvider).currentUser?.phone;
});
