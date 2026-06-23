import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/point_category.dart';
import '../../resilience/controllers/resilience_points_controller.dart';
import '../models/map_marker.dart';
import '../models/water_point.dart';
import 'water_points_controller.dart';

/// Combines water points and resilience points into a single, filtered list of
/// [MapMarker]s for the clustered Mapbox source.
final mapMarkersProvider = Provider<List<MapMarker>>((ref) {
  final selected = ref.watch(mapFilterControllerProvider);
  final markers = <MapMarker>[];

  // Water points (the `other` bucket is always shown).
  final water =
      ref.watch(waterPointsControllerProvider).valueOrNull ??
      const <WaterPoint>[];
  for (final p in water) {
    final category = p.category;
    if (category == PointCategory.other || selected.contains(category)) {
      markers.add(
        MapMarker(
          featureId: MapMarker.waterId(p.id),
          latitude: p.latitude,
          longitude: p.longitude,
          category: category,
        ),
      );
    }
  }

  // Resilience points (only when their filter is active).
  if (selected.contains(PointCategory.resilience)) {
    final resilience =
        ref.watch(resiliencePointsControllerProvider).valueOrNull ?? const [];
    for (final p in resilience) {
      if (!p.hasCoordinates) continue;
      markers.add(
        MapMarker(
          featureId: MapMarker.resilienceId(p.id),
          latitude: p.latitude!,
          longitude: p.longitude!,
          category: PointCategory.resilience,
        ),
      );
    }
  }

  return markers;
});
