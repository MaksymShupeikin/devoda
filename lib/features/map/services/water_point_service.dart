import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/water_point.dart';

/// Raw data access for the `point` table. No UI state lives here.
class WaterPointService {
  WaterPointService(this._client);

  final SupabaseClient _client;

  static const String _table = 'point';

  /// Fetches all active water points. The btree index on
  /// `(latitude, longitude)` plus the `status` index keep this fast.
  Future<List<WaterPoint>> fetchActive({int limit = 5000}) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('status', 'active')
        .limit(limit);

    return (response as List)
        .map((json) => WaterPoint.fromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final waterPointServiceProvider = Provider<WaterPointService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WaterPointService(client);
});
