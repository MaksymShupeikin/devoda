import 'dart:convert';

import 'package:flutter/material.dart';
// Mapbox ships its own `Size` (pigeon) which would clash with dart:ui's Size.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/water_category.dart';
import '../../../../core/utils/widget_to_image.dart';
import '../../models/water_point.dart';
import 'marker_card.dart';

/// Source/layer ids and the helpers that wire a clustered GeoJSON layer stack
/// into a Mapbox style. Keeping this together makes the map widget thin.
class MapLayers {
  MapLayers._();

  static const String sourceId = 'water-points-source';
  static const String clusterCircleLayer = 'water-points-clusters';
  static const String clusterCountLayer = 'water-points-cluster-count';
  static const String unclusteredLayer = 'water-points-unclustered';

  /// Mapbox color expressions expect hex color strings, not ints.
  static String _hex(Color color) {
    final argb = color.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  /// Builds the GeoJSON FeatureCollection string for the given points. Each
  /// feature carries the registered marker image id in its `icon` property.
  static String featureCollection(List<WaterPoint> points) {
    final features = points
        .map((p) => {
              'type': 'Feature',
              'geometry': {
                'type': 'Point',
                'coordinates': [p.longitude, p.latitude],
              },
              'properties': {
                'id': p.id,
                'icon': p.category.markerImageId,
                'category': p.category.name,
              },
            })
        .toList();
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  /// Renders each category's [MarkerCard] off-screen and registers it as a
  /// style image so the symbol layer can reference it by name.
  static Future<void> registerMarkerImages(
    StyleManager style, {
    double pixelRatio = 3.0,
  }) async {
    for (final category in WaterCategory.values) {
      final rendered = await WidgetToImage.toRawRgba(
        MarkerCard(category: category),
        logicalSize: const Size(MarkerCard.width, MarkerCard.height),
        pixelRatio: pixelRatio,
      );
      await style.addStyleImage(
        category.markerImageId,
        rendered.pixelRatio,
        MbxImage(
          width: rendered.widthPx,
          height: rendered.heightPx,
          data: rendered.bytes,
        ),
        false, // not an SDF image
        const <ImageStretches>[],
        const <ImageStretches>[],
        null,
      );
    }
  }

  /// Adds the clustered source and the three rendering layers. Safe to call
  /// once per style load.
  static Future<void> install(
    StyleManager style, {
    required String initialData,
  }) async {
    await style.addSource(
      GeoJsonSource(
        id: sourceId,
        data: initialData,
        cluster: true,
        clusterRadius: 60,
        clusterMaxZoom: 14,
      ),
    );

    // Cluster bubbles: bigger and darker as the count grows.
    await style.addLayer(
      CircleLayer(
        id: clusterCircleLayer,
        sourceId: sourceId,
        filter: ['has', 'point_count'],
        circleColorExpression: [
          'step',
          ['get', 'point_count'],
          _hex(AppColors.accent),
          25,
          _hex(AppColors.primary),
          100,
          _hex(AppColors.primaryDark),
        ],
        circleRadiusExpression: [
          'step',
          ['get', 'point_count'],
          24.0,
          25,
          30.0,
          100,
          38.0,
        ],
        circleStrokeColor: AppColors.surface.toARGB32(),
        circleStrokeWidth: 4.0,
        circleOpacity: 0.95,
      ),
    );

    // Cluster count label.
    await style.addLayer(
      SymbolLayer(
        id: clusterCountLayer,
        sourceId: sourceId,
        filter: ['has', 'point_count'],
        textFieldExpression: ['get', 'point_count_abbreviated'],
        textSize: 18.0,
        textColor: AppColors.surface.toARGB32(),
        textIgnorePlacement: true,
        textAllowOverlap: true,
      ),
    );

    // Individual markers (our baked card images).
    await style.addLayer(
      SymbolLayer(
        id: unclusteredLayer,
        sourceId: sourceId,
        filter: [
          '!',
          ['has', 'point_count'],
        ],
        iconImageExpression: ['get', 'icon'],
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );
  }

  /// Replaces the data of the clustered source (called when points or the
  /// filter change).
  static Future<void> updateData(
    StyleManager style,
    List<WaterPoint> points,
  ) async {
    await style.setStyleSourceProperty(
      sourceId,
      'data',
      featureCollection(points),
    );
  }
}
