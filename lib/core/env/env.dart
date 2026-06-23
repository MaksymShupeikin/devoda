import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Strongly-typed access to values loaded from the `.env` file.
///
/// The `.env` file is bundled as a Flutter asset (see `pubspec.yaml`) and
/// loaded once during [AppInitializer.init].
class Env {
  Env._();

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static String get mapboxPublicToken => _require('MAPBOX_PUBLIC_TOKEN');

  /// Optional custom Mapbox style. Falls back to the Mapbox Standard style.
  static String get mapboxStyleUrl =>
      dotenv.maybeGet('MAPBOX_STYLE_URL')?.trim().isNotEmpty == true
      ? dotenv.get('MAPBOX_STYLE_URL').trim()
      : 'mapbox://styles/mapbox/standard';

  static String _require(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable "$key". '
        'Add it to the .env file at the project root.',
      );
    }
    return value;
  }
}
