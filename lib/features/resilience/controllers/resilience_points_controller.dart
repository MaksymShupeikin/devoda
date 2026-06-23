import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resilience_point.dart';
import '../services/resilience_point_cache.dart';
import '../services/resilience_point_service.dart';

/// Owns the list of resilience points. Cache-first, then refreshes from
/// Supabase in the background — same strategy as the water points.
class ResiliencePointsController extends AsyncNotifier<List<ResiliencePoint>> {
  @override
  Future<List<ResiliencePoint>> build() async {
    final cached = ref.read(resiliencePointCacheProvider).load();
    if (cached.isNotEmpty) {
      Future.microtask(_refreshFromNetwork);
      return cached;
    }
    return _fetchAndCache();
  }

  Future<List<ResiliencePoint>> _fetchAndCache() async {
    final points = await ref.read(resiliencePointServiceProvider).fetchAll();
    await ref.read(resiliencePointCacheProvider).save(points);
    return points;
  }

  Future<void> _refreshFromNetwork() async {
    try {
      state = AsyncData(await _fetchAndCache());
    } catch (_) {
      // Offline or transient error — keep cached data.
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ResiliencePoint>>().copyWithPrevious(state);
    try {
      state = AsyncData(await _fetchAndCache());
    } catch (e, st) {
      final cached = ref.read(resiliencePointCacheProvider).load();
      state = cached.isNotEmpty ? AsyncData(cached) : AsyncError(e, st);
    }
  }
}

final resiliencePointsControllerProvider =
    AsyncNotifierProvider<ResiliencePointsController, List<ResiliencePoint>>(
      ResiliencePointsController.new,
    );
