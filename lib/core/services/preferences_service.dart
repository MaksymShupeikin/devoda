import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the singleton [SharedPreferences] instance.
///
/// The real instance is loaded once in `main()` and injected via a
/// `ProviderScope` override, so the rest of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the loaded '
    'SharedPreferences instance.',
  );
});
