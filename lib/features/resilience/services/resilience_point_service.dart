import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/resilience_point.dart';

/// Raw data access for the `resilience_points` table. No UI state here.
class ResiliencePointService {
  ResiliencePointService(this._client);

  final SupabaseClient _client;

  static const String _table = 'resilience_points';

  /// Fetches resilience points that have coordinates.
  Future<List<ResiliencePoint>> fetchAll({int limit = 5000}) async {
    debugPrint(
      '[devoda] ResiliencePointService: fetchAll starting query for table $_table...',
    );
    try {
      final response = await _client
          .from(_table)
          .select()
          .not('lat', 'is', null)
          .not('lon', 'is', null)
          .limit(limit);

      final list = response as List;
      debugPrint(
        '[devoda] ResiliencePointService: fetchAll success. Returned ${list.length} rows.',
      );
      return list
          .map((json) => ResiliencePoint.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e, st) {
      debugPrint(
        '[devoda] ResiliencePointService: fetchAll error: $e\nStacktrace: $st',
      );
      rethrow;
    }
  }
}

final resiliencePointServiceProvider = Provider<ResiliencePointService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ResiliencePointService(client);
});
