import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

/// Centralized, ordered startup. Everything that must complete before
/// `runApp` lives here, keeping `main()` minimal.
class AppInitializer {
  AppInitializer._();

  /// Runs all async startup work and returns the loaded [SharedPreferences],
  /// which is then injected into the widget tree via a provider override.
  static Future<SharedPreferences> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Environment variables (tokens & urls).
    await dotenv.load(fileName: '.env');

    // 2. Mapbox access token for the native SDK.
    MapboxOptions.setAccessToken(Env.mapboxPublicToken);

    // 3. Supabase client.
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );

    // 4. Local persistence (onboarding flag + offline marker cache).
    final prefs = await SharedPreferences.getInstance();

    return prefs;
  }
}
