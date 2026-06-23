import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_controller.dart';
import '../services/auth_service.dart';

enum LoginStep { phone, code }

/// Immutable state for the phone + OTP login flow.
class LoginState {
  const LoginState({
    this.step = LoginStep.phone,
    this.submitting = false,
    this.error,
    this.e164Phone = '',
  });

  final LoginStep step;
  final bool submitting;
  final String? error;
  final String e164Phone;

  static const LoginState initial = LoginState();

  LoginState copyWith({
    LoginStep? step,
    bool? submitting,
    String? error,
    bool clearError = false,
    String? e164Phone,
  }) {
    return LoginState(
      step: step ?? this.step,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
      e164Phone: e164Phone ?? this.e164Phone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginState &&
        other.step == step &&
        other.submitting == submitting &&
        other.error == error &&
        other.e164Phone == e164Phone;
  }

  @override
  int get hashCode => Object.hash(step, submitting, error, e164Phone);

  @override
  String toString() =>
      'LoginState(step: $step, submitting: $submitting, error: $error)';
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => LoginState.initial;

  /// Sends the SMS code and advances to the code step on success.
  Future<void> sendCode(String e164Phone) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(authServiceProvider).sendOtp(e164Phone);
      state = state.copyWith(
        submitting: false,
        step: LoginStep.code,
        e164Phone: e164Phone,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(submitting: false, error: _message(e));
    }
  }

  /// Verifies the code. Returns true on success (session established).
  Future<bool> verifyCode(String token) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref
          .read(authServiceProvider)
          .verifyOtp(e164Phone: state.e164Phone, token: token);
      state = state.copyWith(submitting: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(submitting: false, error: _message(e));
      return false;
    }
  }

  void editPhone() => state = state.copyWith(
    step: LoginStep.phone,
    clearError: true,
    submitting: false,
  );

  void reset() => state = LoginState.initial;

  String _message(Object error) {
    final l = AppLocalizations(ref.read(localeControllerProvider));
    final text = error.toString();
    if (text.contains('Invalid') || text.contains('expired')) {
      return l.invalidCode;
    }
    return l.loginFailed;
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
