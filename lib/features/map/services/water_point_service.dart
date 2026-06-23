import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/water_point.dart';

/// Raw data access for the `point` table. No UI state lives here.
class WaterPointService {
  WaterPointService(this._client);

  final SupabaseClient _client;

  static const String _table = 'water_points';

  /// Fetches all active water points. The btree index on
  /// `(latitude, longitude)` plus the `status` index keep this fast.
  Future<List<WaterPoint>> fetchActive({int limit = 5000}) async {
    debugPrint(
      '[devoda] WaterPointService: fetchActive starting query for table $_table...',
    );
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('status', 'active')
          .limit(limit);

      final list = response as List;
      debugPrint(
        '[devoda] WaterPointService: fetchActive success. Returned ${list.length} rows.',
      );
      return list
          .map((json) => WaterPoint.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e, st) {
      debugPrint(
        '[devoda] WaterPointService: fetchActive error: $e\nStacktrace: $st',
      );
      rethrow;
    }
  }

  Future<WaterPoint> insertPoint({
    required String amenity,
    required String type,
    required double latitude,
    required double longitude,
    String? name,
  }) async {
    final payload = <String, dynamic>{
      'osm_id': 'manual:${DateTime.now().millisecondsSinceEpoch}',
      'amenity': amenity,
      'name': name,
      'region': 'manual',
      'tags': <String, dynamic>{},
      'type': type,
      'status': 'active',
      'latitude': latitude,
      'longitude': longitude,
    };

    debugPrint('[devoda] WaterPointService: insertPoint payload: $payload');
    try {
      final response = await _client
          .from(_table)
          .insert(payload)
          .select()
          .single();
      debugPrint('[devoda] WaterPointService: insertPoint success.');
      return WaterPoint.fromJson(response);
    } catch (e, st) {
      debugPrint(
        '[devoda] WaterPointService: insertPoint error: $e\nStacktrace: $st',
      );
      rethrow;
    }
  }
}

final waterPointServiceProvider = Provider<WaterPointService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WaterPointService(client);
});
