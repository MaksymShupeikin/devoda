import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/app_initializer.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  final prefs = await AppInitializer.init();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DevodaApp(),
    ),
  );
}
