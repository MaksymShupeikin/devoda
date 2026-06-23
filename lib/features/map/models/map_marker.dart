import '../../../core/utils/point_category.dart';

/// Minimal data the map needs to render and identify a marker. Both water
/// points and resilience points are projected into this shape so they share a
/// single clustered GeoJSON source.
///
/// [featureId] is namespaced (`w:<id>` / `r:<id>`) so a tap can be routed back
/// to the correct dataset.
class MapMarker {
  const MapMarker({
    required this.featureId,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  final String featureId;
  final double latitude;
  final double longitude;
  final PointCategory category;

  static String waterId(int id) => 'w:$id';
  static String resilienceId(int id) => 'r:$id';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapMarker &&
        other.featureId == featureId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(featureId, latitude, longitude, category);

  @override
  String toString() => 'MapMarker($featureId, $latitude, $longitude)';
}
