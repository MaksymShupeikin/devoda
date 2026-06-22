import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/env/env.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/water_category.dart';
import '../../controllers/water_points_controller.dart';
import '../../models/water_point.dart';
import 'add_point_sheet.dart';
import 'category_filter_bar.dart';
import 'map_controls.dart';
import 'offline_download_sheet.dart';
import 'placement_overlay.dart';
import 'point_details_sheet.dart';
import 'map_layers.dart';

/// Default camera target used until the user's location is known.
const _fallbackCenter = (lat: 50.4501, lng: 30.5234); // Kyiv

/// The full interactive map surface: Mapbox map, clustered markers, filters,
/// controls and the add-point placement flow.
class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  mb.MapboxMap? _map;
  bool _styleReady = false;
  bool _placementMode = false;

  Future<void> _onMapCreated(mb.MapboxMap map) async {
    _map = map;
    // Fallback camera until the user's location is resolved.
    await map.setCamera(
      mb.CameraOptions(
        center: mb.Point(
          coordinates: mb.Position(_fallbackCenter.lng, _fallbackCenter.lat),
        ),
        zoom: 11,
      ),
    );
    // Show the user's location puck.
    await map.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        showAccuracyRing: true,
      ),
    );
    // Hide default Mapbox branding ornaments (scale bar, attribution, logo)
    await map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
    await map.attribution.updateSettings(mb.AttributionSettings(enabled: false));
    await map.logo.updateSettings(mb.LogoSettings(enabled: false));
  }

  Future<void> _onStyleLoaded(mb.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;

    await MapLayers.registerMarkerImages(map.style);
    await MapLayers.install(
      map.style,
      initialData: MapLayers.featureCollection(
        ref.read(filteredWaterPointsProvider),
      ),
    );

    // Tap interactions bound to our layers hand the feature straight to the
    // callback (no manual query). Fixed ids keep re-registration idempotent.
    map.addInteraction(
      mb.TapInteraction(
        mb.FeaturesetDescriptor(layerId: MapLayers.unclusteredLayer),
        (feature, _) => _handlePointTap(feature),
      ),
      interactionID: 'water-point-tap',
    );
    map.addInteraction(
      mb.TapInteraction(
        mb.FeaturesetDescriptor(layerId: MapLayers.clusterCircleLayer),
        (feature, _) => _handleClusterTap(feature),
      ),
      interactionID: 'water-cluster-tap',
    );

    if (!mounted) return;
    setState(() => _styleReady = true);
    await _moveToUserLocation(animate: false);
  }

  Future<void> _moveToUserLocation({bool animate = true}) async {
    final map = _map;
    if (map == null) return;
    final position = await ref.read(locationServiceProvider).currentPosition();
    final target = position != null
        ? mb.Point(
            coordinates: mb.Position(position.longitude, position.latitude),
          )
        : mb.Point(
            coordinates:
                mb.Position(_fallbackCenter.lng, _fallbackCenter.lat),
          );
    final camera = mb.CameraOptions(center: target, zoom: 14);
    if (animate) {
      await map.flyTo(camera, mb.MapAnimationOptions(duration: 900));
    } else {
      await map.setCamera(camera);
    }
  }

  Future<void> _syncSource() async {
    final map = _map;
    if (!_styleReady || map == null) return;
    await MapLayers.updateData(map.style, ref.read(filteredWaterPointsProvider));
  }

  /// A single marker was tapped — open its details. Ignored while placing a
  /// new point (the center crosshair defines that location).
  void _handlePointTap(mb.FeaturesetFeature feature) {
    if (_placementMode) return;
    final id = feature.properties['id'];
    if (id is num) _openDetails(id.toInt());
  }

  /// A cluster bubble was tapped — zoom in to break it apart.
  Future<void> _handleClusterTap(mb.FeaturesetFeature feature) async {
    if (_placementMode) return;
    final map = _map;
    if (map == null) return;
    final coordinates = feature.geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return;

    final current = await map.getCameraState();
    await map.flyTo(
      mb.CameraOptions(
        center: mb.Point(
          coordinates: mb.Position(
            (coordinates[0] as num).toDouble(),
            (coordinates[1] as num).toDouble(),
          ),
        ),
        zoom: (current.zoom + 2).clamp(0, 20).toDouble(),
      ),
      mb.MapAnimationOptions(duration: 700),
    );
  }

  void _openDetails(int id) {
    final points = ref.read(waterPointsControllerProvider).valueOrNull ??
        const <WaterPoint>[];
    WaterPoint? point;
    for (final p in points) {
      if (p.id == id) {
        point = p;
        break;
      }
    }
    if (point == null) return;
    PointDetailsSheet.show(context, point);
  }

  // ---- Controls -----------------------------------------------------------

  Future<void> _onLocatePressed() async {
    final granted = await ref.read(locationServiceProvider).ensurePermission();
    if (!granted) {
      _showSnack('Включите геолокацию, чтобы найти себя на карте');
      return;
    }
    await _moveToUserLocation(animate: true);
  }

  Future<void> _onOfflinePressed() async {
    final camera = await _map?.getCameraState();
    final center = camera?.center.coordinates;
    if (center == null) return;
    if (!mounted) return;
    OfflineDownloadSheet.show(
      context,
      latitude: center.lat.toDouble(),
      longitude: center.lng.toDouble(),
    );
  }

  void _enterPlacement() => setState(() => _placementMode = true);

  void _cancelPlacement() => setState(() => _placementMode = false);

  Future<void> _confirmPlacement() async {
    final camera = await _map?.getCameraState();
    final center = camera?.center.coordinates;
    if (center == null || !mounted) return;

    final result = await AddPointSheet.show(context);
    if (result == null || !mounted) return;

    final now = DateTime.now();
    final point = WaterPoint(
      // Negative id keeps locally-added (mock) points distinct from server ids.
      id: -now.millisecondsSinceEpoch,
      osmId: 'manual:${now.millisecondsSinceEpoch}',
      amenity: result.category.amenityValue,
      name: result.name,
      region: 'manual',
      tags: const {},
      type: result.category.amenityValue,
      status: 'active',
      latitude: center.lat.toDouble(),
      longitude: center.lng.toDouble(),
    );
    await ref.read(waterPointsControllerProvider.notifier).addLocalMock(point);

    if (!mounted) return;
    setState(() => _placementMode = false);
    _showSnack('Точка добавлена. Спасибо!');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Keep the Mapbox source in sync with the filtered points.
    ref.listen(filteredWaterPointsProvider, (_, _) => _syncSource());

    return Stack(
      children: [
        Positioned.fill(
          child: mb.MapWidget(
            styleUri: Env.mapboxStyleUrl,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
          ),
        ),

        if (!_placementMode) ...[
          // Bottom darkening gradient & CategoryFilterBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
              child: const SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20, top: 40),
                  child: CategoryFilterBar(),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 110,
            child: SafeArea(
              child: MapControls(
                onLocate: _onLocatePressed,
                onRefresh: () =>
                    ref.read(waterPointsControllerProvider.notifier).refresh(),
                onOffline: _onOfflinePressed,
                onAdd: _enterPlacement,
              ),
            ),
          ),
        ],

        if (_placementMode)
          PlacementOverlay(
            onCancel: _cancelPlacement,
            onConfirm: _confirmPlacement,
          ),

        // Until the style finishes loading, hide the empty map behind a veil.
        if (!_styleReady)
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.background,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
