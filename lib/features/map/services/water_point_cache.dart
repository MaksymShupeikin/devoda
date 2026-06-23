import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/preferences_service.dart';
import '../models/water_point.dart';

/// Persists fetched water points to SharedPreferences so the map can show
/// markers instantly on launch and keep working fully offline.
class WaterPointCache {
  WaterPointCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _pointsKey = 'water_points_cache_v1';
  static const String _updatedKey = 'water_points_cache_updated_at_v1';

  /// Reads cached points. Returns an empty list when nothing is cached or the
  /// stored payload is corrupt.
  List<WaterPoint> load() {
    final raw = _prefs.getString(_pointsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => WaterPoint.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  DateTime? lastUpdated() {
    final millis = _prefs.getInt(_updatedKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> save(List<WaterPoint> points) async {
    final encoded = jsonEncode(points.map((p) => p.toJson()).toList());
    await _prefs.setString(_pointsKey, encoded);
    await _prefs.setInt(_updatedKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final waterPointCacheProvider = Provider<WaterPointCache>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WaterPointCache(prefs);
});
