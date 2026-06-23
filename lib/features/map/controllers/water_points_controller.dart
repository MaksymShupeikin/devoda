import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/point_category.dart';
import '../models/water_point.dart';
import '../services/water_point_cache.dart';
import '../services/water_point_service.dart';

/// Owns the list of water points shown on the map.
///
/// Strategy: return cached points instantly (so markers appear on launch and
/// while offline), then refresh from Supabase in the background.
class WaterPointsController extends AsyncNotifier<List<WaterPoint>> {
  @override
  Future<List<WaterPoint>> build() async {
    final cached = ref.read(waterPointCacheProvider).load();
    if (cached.isNotEmpty) {
      // Instant markers, fresh data arrives shortly after.
      Future.microtask(_refreshFromNetwork);
      return cached;
    }
    return _fetchAndCache();
  }

  Future<List<WaterPoint>> _fetchAndCache() async {
    final points = await ref.read(waterPointServiceProvider).fetchActive();
    await ref.read(waterPointCacheProvider).save(points);
    return points;
  }

  Future<void> _refreshFromNetwork() async {
    try {
      state = AsyncData(await _fetchAndCache());
    } catch (_) {
      // Offline or transient error — keep showing cached data.
    }
  }

  /// Manual refresh (e.g. the reload button). Keeps cached data visible if the
  /// network is unavailable.
  Future<void> refresh() async {
    state = const AsyncLoading<List<WaterPoint>>().copyWithPrevious(state);
    try {
      state = AsyncData(await _fetchAndCache());
    } catch (e, st) {
      final cached = ref.read(waterPointCacheProvider).load();
      state = cached.isNotEmpty ? AsyncData(cached) : AsyncError(e, st);
    }
  }

  /// Inserts a new water point into Supabase, then optimistically adds it to
  /// the visible list and offline cache. Throws if the insert fails (e.g. RLS).
  ///
  /// The real row (with its server id) replaces the optimistic copy on the next
  /// refresh.
  Future<void> addWaterPoint({
    required String amenity,
    required String type,
    required double latitude,
    required double longitude,
    String? name,
  }) async {
    final point = await ref
        .read(waterPointServiceProvider)
        .insertPoint(
          amenity: amenity,
          type: type,
          latitude: latitude,
          longitude: longitude,
          name: name,
        );

    final current = state.valueOrNull ?? const <WaterPoint>[];
    final updated = [...current, point];
    state = AsyncData(updated);
    await ref.read(waterPointCacheProvider).save(updated);
  }
}

final waterPointsControllerProvider =
    AsyncNotifierProvider<WaterPointsController, List<WaterPoint>>(
      WaterPointsController.new,
    );

/// Selected categories. All are enabled by default.
class MapFilterController extends Notifier<Set<PointCategory>> {
  @override
  Set<PointCategory> build() => PointCategoryX.selectable.toSet();

  void toggle(PointCategory category) {
    final next = {...state};
    if (next.contains(category)) {
      // Keep at least one category enabled.
      if (next.length == 1) return;
      next.remove(category);
    } else {
      next.add(category);
    }
    state = next;
  }

  bool isSelected(PointCategory category) => state.contains(category);
}

final mapFilterControllerProvider =
    NotifierProvider<MapFilterController, Set<PointCategory>>(
      MapFilterController.new,
    );
