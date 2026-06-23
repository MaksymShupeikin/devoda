import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';

/// Current app locale, persisted in SharedPreferences. Defaults to Ukrainian.
class LocaleController extends Notifier<Locale> {
  static const String _key = 'app_locale_v1';
  static const Locale _fallback = Locale('uk');

  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(_key);
    return code == null ? _fallback : Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    await ref.read(sharedPreferencesProvider).setString(
          _key,
          locale.languageCode,
        );
    state = locale;
  }

  Future<void> toggle() => setLocale(
        state.languageCode == 'uk' ? const Locale('en') : const Locale('uk'),
      );
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
