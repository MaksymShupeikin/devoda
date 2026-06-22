import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/water_category.dart';
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

  /// Optimistically adds a locally created point (mock submission flow) and
  /// persists it to the offline cache.
  Future<void> addLocalMock(WaterPoint point) async {
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

/// Points after applying the active category filter. The `other` bucket is
/// always shown since it is not user-filterable.
final filteredWaterPointsProvider = Provider<List<WaterPoint>>((ref) {
  final points = ref.watch(waterPointsControllerProvider).valueOrNull ??
      const <WaterPoint>[];
  final selected = ref.watch(mapFilterControllerProvider);
  return points.where((p) {
    final category = p.category;
    return category == WaterCategory.other || selected.contains(category);
  }).toList(growable: false);
});

/// Selected categories. All are enabled by default.
class MapFilterController extends Notifier<Set<WaterCategory>> {
  @override
  Set<WaterCategory> build() => WaterCategoryX.selectable.toSet();

  void toggle(WaterCategory category) {
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

  bool isSelected(WaterCategory category) => state.contains(category);
}

final mapFilterControllerProvider =
    NotifierProvider<MapFilterController, Set<WaterCategory>>(
  MapFilterController.new,
);
