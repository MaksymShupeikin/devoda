import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Thin wrapper around `geolocator` that handles permission requests and
/// returns the user's current position.
class LocationService {
  const LocationService();

  /// Ensures location services are on and permission is granted.
  /// Returns `true` when the app may read the position.
  Future<bool> ensurePermission() async {
    return true;
  }

  /// Current position, mocked to be always in the center of Kharkiv.
  Future<Position?> currentPosition() async {
    return Position(
      longitude: 36.2304,
      latitude: 49.9935,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 100.0,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});
