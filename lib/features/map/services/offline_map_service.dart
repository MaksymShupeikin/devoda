import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/env/env.dart';

/// Downloads a square area of the Mapbox map (tiles + style pack) around a
/// center point for offline use. Progress is reported as a 0..1 fraction.
class OfflineMapService {
  static const String tileRegionId = 'devoda-offline-region';

  /// Builds a square polygon (GeoJSON) of [radiusKm] half-side around the
  /// given center.
  Map<String, Object?> _squareAround(
    double lat,
    double lng,
    double radiusKm,
  ) {
    const double kmPerDegLat = 111.0;
    final double kmPerDegLng =
        111.0 * math.cos(lat * math.pi / 180.0).abs().clamp(0.01, 1.0);
    final double dLat = radiusKm / kmPerDegLat;
    final double dLng = radiusKm / kmPerDegLng;

    return {
      'type': 'Polygon',
      'coordinates': [
        [
          [lng - dLng, lat - dLat],
          [lng + dLng, lat - dLat],
          [lng + dLng, lat + dLat],
          [lng - dLng, lat + dLat],
          [lng - dLng, lat - dLat],
        ],
      ],
    };
  }

  /// Downloads everything needed to render the area offline.
  ///
  /// [onProgress] is called with a value between 0 and 1.
  Future<void> downloadAround({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
    int minZoom = 10,
    int maxZoom = 16,
    void Function(double progress)? onProgress,
  }) async {
    final styleUri = Env.mapboxStyleUrl;

    // 1. Style pack (sprites, glyphs, style json) — first ~50% of the bar.
    final offlineManager = await OfflineManager.create();
    await offlineManager.loadStylePack(
      styleUri,
      StylePackLoadOptions(
        glyphsRasterizationMode:
            GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
        metadata: {'id': tileRegionId},
        acceptExpired: true,
      ),
      (progress) {
        final required = progress.requiredResourceCount;
        if (required <= 0) return;
        final fraction = progress.completedResourceCount / required;
        onProgress?.call(0.5 * fraction.clamp(0.0, 1.0));
      },
    );

    // 2. Map tiles for the area — second ~50% of the bar.
    final tileStore = await TileStore.createDefault();
    await tileStore.loadTileRegion(
      tileRegionId,
      TileRegionLoadOptions(
        geometry: _squareAround(latitude, longitude, radiusKm),
        descriptorsOptions: [
          TilesetDescriptorOptions(
            styleURI: styleUri,
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
        ],
        acceptExpired: true,
        networkRestriction: NetworkRestriction.NONE,
      ),
      (progress) {
        final required = progress.requiredResourceCount;
        if (required <= 0) return;
        final fraction = progress.completedResourceCount / required;
        onProgress?.call(0.5 + 0.5 * fraction.clamp(0.0, 1.0));
      },
    );

    onProgress?.call(1.0);
  }

  /// Removes the previously downloaded offline region.
  Future<void> clear() async {
    final tileStore = await TileStore.createDefault();
    await tileStore.removeRegion(tileRegionId);
  }
}

final offlineMapServiceProvider = Provider<OfflineMapService>((ref) {
  return OfflineMapService();
});
