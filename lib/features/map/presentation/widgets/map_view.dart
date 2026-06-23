import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../../core/env/env.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../controllers/map_markers_provider.dart';
import '../../controllers/water_points_controller.dart';
import '../../services/add_rate_limiter.dart';
import '../../models/water_point.dart';
import '../../../resilience/models/resilience_point.dart';
import '../../../resilience/controllers/resilience_points_controller.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/account_sheet.dart';
import '../../../resilience/presentation/widgets/resilience_details_sheet.dart';
import 'add_point_sheet.dart';
import 'category_filter_bar.dart';
import 'map_controls.dart';
import 'offline_download_sheet.dart';
import 'placement_overlay.dart';
import 'point_details_sheet.dart';
import 'map_layers.dart';
import '../../../../core/widgets/water_droplet_loader.dart';
import '../../../../core/l10n/locale_controller.dart';

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
  String? _selectedFeatureId;

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
    // Hide default Mapbox branding ornaments (scale bar, attribution, logo, compass)
    await map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
    await map.attribution.updateSettings(
      mb.AttributionSettings(enabled: false),
    );
    await map.logo.updateSettings(mb.LogoSettings(enabled: false));
    await map.compass.updateSettings(mb.CompassSettings(enabled: false));
  }

  Future<void> _onStyleLoaded(mb.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;

    try {
      await MapLayers.registerMarkerImages(map.style);
      await MapLayers.install(
        map.style,
        initialData: MapLayers.featureCollection(ref.read(mapMarkersProvider)),
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
    } catch (e, st) {
      debugPrint('[devoda] _onStyleLoaded error: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _styleReady = true);
        await _moveToUserLocation(animate: false);
      }
    }
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
            coordinates: mb.Position(_fallbackCenter.lng, _fallbackCenter.lat),
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
    await MapLayers.updateData(
      map.style,
      ref.read(mapMarkersProvider),
      selectedId: _selectedFeatureId,
    );
  }

  /// A single marker was tapped — open its details. Ignored while placing a
  /// new point (the center crosshair defines that location).
  void _handlePointTap(mb.FeaturesetFeature feature) {
    if (_placementMode) return;
    final id = feature.properties['id'];
    if (id is String) _openDetails(id);
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

  /// Marks [id] as selected (enlarging that marker) and re-pushes the source.
  Future<void> _selectMarker(String? id) async {
    _selectedFeatureId = id;
    await _syncSource();
  }

  Future<void> _openDetails(String id) async {
    // Enlarge the tapped marker right away as press feedback.
    await _selectMarker(id);

    if (id.startsWith('w:')) {
      final waterId = int.tryParse(id.substring(2));
      WaterPoint? point;
      if (waterId != null) {
        final points =
            ref.read(waterPointsControllerProvider).valueOrNull ??
            const <WaterPoint>[];
        for (final p in points) {
          if (p.id == waterId) {
            point = p;
            break;
          }
        }
      }
      if (point != null && mounted) {
        await PointDetailsSheet.show(context, point);
      }
    } else if (id.startsWith('r:')) {
      final resilienceId = int.tryParse(id.substring(2));
      ResiliencePoint? point;
      if (resilienceId != null) {
        final points =
            ref.read(resiliencePointsControllerProvider).valueOrNull ??
            const <ResiliencePoint>[];
        for (final p in points) {
          if (p.id == resilienceId) {
            point = p;
            break;
          }
        }
      }
      if (point != null && mounted) {
        await ResilienceDetailsSheet.show(context, point);
      }
    }

    // Restore the normal size once the details sheet is dismissed.
    await _selectMarker(null);
  }

  // ---- Controls -----------------------------------------------------------

  Future<void> _onLocatePressed() async {
    final l10n = context.l10n;
    final granted = await ref.read(locationServiceProvider).ensurePermission();
    if (!granted) {
      AppNotify.info(l10n.enableLocation);
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

  /// Hides/shows all marker layers (so existing points don't distract while
  /// the user is aiming the crosshair at a new location).
  Future<void> _setMarkersVisible(bool visible) async {
    final map = _map;
    if (!_styleReady || map == null) return;
    await MapLayers.setMarkersVisible(map.style, visible);
  }

  void _onAccountPressed() => AccountSheet.show(context);

  /// Add-point entry: requires the user to be signed in (phone + OTP) and not
  /// be within the anti-spam cooldown.
  Future<void> _onAddPressed() async {
    if (!ref.read(isSignedInProvider)) {
      final signedIn = await context.pushNamed<bool>(LoginPage.name);
      if (signedIn != true || !mounted) return;
    }

    final userId = ref.read(authServiceProvider).currentUser?.id;
    if (userId != null) {
      final left = ref.read(addRateLimiterProvider).remaining(userId);
      if (left != null) {
        final l10n = context.l10n;
        AppNotify.info(
          l10n.addCooldown(
            AddRateLimiter.cooldown.inMinutes,
            _formatLeft(left, l10n),
          ),
        );
        return;
      }
    }

    await _enterPlacement();
  }

  String _formatLeft(Duration d, AppLocalizations l) {
    if (d.inMinutes >= 1) return l.minutesShort(d.inMinutes);
    return l.secondsShort(d.inSeconds + 1);
  }

  Future<void> _enterPlacement() async {
    setState(() => _placementMode = true);
    _setMarkersVisible(false);
    final map = _map;
    if (map == null) return;

    final position = await ref.read(locationServiceProvider).currentPosition();
    final camera = await map.getCameraState();

    final targetCenter = position != null
        ? mb.Point(
            coordinates: mb.Position(position.longitude, position.latitude),
          )
        : camera.center;

    final targetZoom = camera.zoom < 16.5 ? 16.5 : camera.zoom;
    await map.flyTo(
      mb.CameraOptions(center: targetCenter, zoom: targetZoom),
      mb.MapAnimationOptions(duration: 500),
    );
  }

  void _cancelPlacement() {
    setState(() => _placementMode = false);
    _setMarkersVisible(true);
  }

  Future<void> _confirmPlacement() async {
    final camera = await _map?.getCameraState();
    final center = camera?.center.coordinates;
    if (center == null || !mounted) return;

    final result = await AddPointSheet.show(context);
    if (result == null || !mounted) return;

    var success = false;
    String? errorText;
    try {
      await ref
          .read(waterPointsControllerProvider.notifier)
          .addWaterPoint(
            amenity: result.category.amenityValue,
            type: result.category.amenityValue,
            latitude: center.lat.toDouble(),
            longitude: center.lng.toDouble(),
            name: result.name,
          );
      success = true;
      final userId = ref.read(authServiceProvider).currentUser?.id;
      if (userId != null) {
        await ref.read(addRateLimiterProvider).markUsed(userId);
      }
    } catch (e) {
      // Surface the real reason (RLS / missing column / enum mismatch …).
      debugPrint('[devoda] add failed: $e');
      errorText = e is PostgrestException ? e.message : e.toString();
    }

    if (!mounted) return;
    final l10n = context.l10n;
    setState(() => _placementMode = false);
    await _setMarkersVisible(true);
    if (success) {
      AppNotify.success(l10n.pointAdded);
    } else {
      AppNotify.error(errorText ?? l10n.tryAgain);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the Mapbox source in sync with the filtered markers.
    ref.listen(mapMarkersProvider, (_, _) => _syncSource());

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
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 40),
                  child: CategoryFilterBar(),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const SafeArea(top: false, child: SizedBox(height: 80)),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: MapControls(
                onLocate: _onLocatePressed,
                onRefresh: () =>
                    ref.read(waterPointsControllerProvider.notifier).refresh(),
                onOffline: _onOfflinePressed,
                onAdd: _onAddPressed,
                onAccount: ref.watch(isSignedInProvider)
                    ? _onAccountPressed
                    : null,
                onLanguageToggle: () =>
                    ref.read(localeControllerProvider.notifier).toggle(),
                currentLanguageCode: ref
                    .watch(localeControllerProvider)
                    .languageCode
                    .toUpperCase(),
              ),
            ),
          ),
        ],

        if (_placementMode)
          PlacementOverlay(
            onCancel: _cancelPlacement,
            onConfirm: _confirmPlacement,
          ),

        if (!_styleReady)
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.background,
              child: Center(child: WaterDropletLoader(size: 90)),
            ),
          ),
      ],
    );
  }
}
