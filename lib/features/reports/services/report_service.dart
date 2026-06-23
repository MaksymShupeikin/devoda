import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/report.dart';

/// Data access for the `report` table. Requires RLS policies allowing
/// authenticated users to insert and read reports.
class ReportService {
  ReportService(this._client);

  final SupabaseClient _client;

  static const String _table = 'report';

  /// Reports for a point, newest first.
  Future<List<Report>> fetchForPoint(int pointId, {int limit = 100}) async {
    debugPrint(
      '[devoda] ReportService: fetchForPoint starting query for pointId=$pointId...',
    );
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('point_id', pointId)
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List;
      debugPrint(
        '[devoda] ReportService: fetchForPoint success. Returned ${list.length} rows.',
      );
      return list
          .map((json) => Report.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e, st) {
      debugPrint(
        '[devoda] ReportService: fetchForPoint error: $e\nStacktrace: $st',
      );
      rethrow;
    }
  }

  /// Submits a new report. `user_id` defaults to `auth.uid()` and `status`
  /// defaults to `new` server-side.
  Future<void> submit({
    required int pointId,
    required String condition,
    String? description,
  }) async {
    final note = description?.trim();
    final payload = {
      'point_id': pointId,
      'reported_condition': condition,
      'description': (note != null && note.isNotEmpty) ? note : null,
    };
    debugPrint('[devoda] ReportService: submit payload: $payload');
    try {
      await _client.from(_table).insert(payload);
      debugPrint('[devoda] ReportService: submit success.');
    } catch (e, st) {
      debugPrint('[devoda] ReportService: submit error: $e\nStacktrace: $st');
      rethrow;
    }
  }
}

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(supabaseClientProvider));
});

/// Reports for a given point id (refresh with `ref.invalidate`).
final reportsForPointProvider = FutureProvider.family<List<Report>, int>((
  ref,
  pointId,
) {
  return ref.watch(reportServiceProvider).fetchForPoint(pointId);
});
