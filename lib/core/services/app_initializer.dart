import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

class AppInitializer {
  AppInitializer._();

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
