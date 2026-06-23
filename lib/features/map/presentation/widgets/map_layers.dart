import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Mapbox ships its own `Size` (pigeon) which would clash with dart:ui's Size.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/utils/widget_to_image.dart';
import '../../models/map_marker.dart';
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
  /// feature carries the registered marker image id in its `icon` property and
  /// a `selected` flag used to enlarge the tapped marker.
  static String featureCollection(
    List<MapMarker> markers, {
    String? selectedId,
  }) {
    final features = markers
        .map(
          (m) => {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [m.longitude, m.latitude],
            },
            'properties': {
              'id': m.featureId,
              'icon': m.category.markerImageId,
              'category': m.category.name,
              'selected': m.featureId == selectedId,
            },
          },
        )
        .toList();
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  /// Renders each category's [MarkerCard] off-screen and registers it as a
  /// style image so the symbol layer can reference it by name.
  static Future<void> registerMarkerImages(
    StyleManager style, {
    double pixelRatio = 3.0,
  }) async {
    for (final category in PointCategory.values) {
      // Rasterize the category SVG (tinted) and place it inside the card.
      final iconImage = await _rasterizeSvg(
        category.svgAsset,
        color: category.color,
        logicalSize: MarkerCard.iconSize,
        pixelRatio: pixelRatio,
      );
      final Widget iconWidget = iconImage != null
          ? RawImage(
              image: iconImage,
              width: MarkerCard.iconSize,
              height: MarkerCard.iconSize,
              fit: BoxFit.contain,
            )
          : Icon(
              category.icon,
              color: category.color,
              size: MarkerCard.iconSize,
            );

      final rendered = await WidgetToImage.toPngBytes(
        MarkerCard(color: category.color, icon: iconWidget),
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

  /// Rasterizes an SVG asset into a tinted [ui.Image] at [logicalSize] logical
  /// pixels (scaled by [pixelRatio] for crispness). Returns null on failure so
  /// the caller can fall back to a Material glyph.
  static Future<ui.Image?> _rasterizeSvg(
    String assetPath, {
    required Color color,
    required double logicalSize,
    required double pixelRatio,
  }) async {
    try {
      final loader = SvgAssetLoader(
        assetPath,
        theme: SvgTheme(currentColor: color),
      );
      final info = await vg.loadPicture(loader, null);
      final px = (logicalSize * pixelRatio).round();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final src = info.size;
      if (src.width > 0 && src.height > 0) {
        canvas.scale(px / src.width, px / src.height);
      }
      canvas.drawPicture(info.picture);
      final picture = recorder.endRecording();
      final image = await picture.toImage(px, px);
      info.picture.dispose();
      picture.dispose();
      return image;
    } catch (_) {
      return null;
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
        // Tapped marker grows to ~1.45x; others stay at 1x.
        iconSizeExpression: [
          'case',
          ['get', 'selected'],
          1.45,
          1.0,
        ],
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconAnchor: IconAnchor.BOTTOM,
        // Draw the selected marker above its neighbours.
        symbolSortKeyExpression: [
          'case',
          ['get', 'selected'],
          1.0,
          0.0,
        ],
      ),
    );
  }

  /// Replaces the data of the clustered source (called when points or the
  /// filter change).
  static Future<void> updateData(
    StyleManager style,
    List<MapMarker> markers, {
    String? selectedId,
  }) async {
    await style.setStyleSourceProperty(
      sourceId,
      'data',
      featureCollection(markers, selectedId: selectedId),
    );
  }

  /// Shows or hides every marker layer at once (used to clear the map while the
  /// user is placing a new point).
  static Future<void> setMarkersVisible(
    StyleManager style,
    bool visible,
  ) async {
    final value = visible ? 'visible' : 'none';
    for (final layerId in const [
      clusterCircleLayer,
      clusterCountLayer,
      unclusteredLayer,
    ]) {
      await style.setStyleLayerProperty(layerId, 'visibility', value);
    }
  }
}
