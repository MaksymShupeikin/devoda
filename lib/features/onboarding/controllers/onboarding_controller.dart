import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';

/// Tracks whether the user has completed the first-run intro.
class OnboardingController extends Notifier<bool> {
  static const String _key = 'onboarding_seen_v1';

  @override
  bool build() {
    // TODO(test): Always return false to show onboarding on every app launch for testing.
    return false;
    // return ref.read(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  Future<void> complete() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
