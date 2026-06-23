import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/preferences_service.dart';
import '../models/resilience_point.dart';

/// Persists resilience points to SharedPreferences for instant display on
/// launch and full offline use (mirrors the water-point cache).
class ResiliencePointCache {
  ResiliencePointCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'resilience_points_cache_v1';

  List<ResiliencePoint> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ResiliencePoint.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<ResiliencePoint> points) async {
    final encoded = jsonEncode(points.map((p) => p.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }
}

final resiliencePointCacheProvider = Provider<ResiliencePointCache>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ResiliencePointCache(prefs);
});
