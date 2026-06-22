import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Opens the device's default map application with turn-by-turn navigation to
/// the given coordinate. Falls back to a universal Google Maps web link if no
/// native map app handles the request.
class MapNavigation {
  MapNavigation._();

  static Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final candidates = <Uri>[
      if (Platform.isIOS)
        Uri.parse(
          'http://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d',
        ),
      if (Platform.isAndroid)
        Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'),
      // geo: scheme — handled by most installed map apps.
      Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude'
        '${label != null ? '(${Uri.encodeComponent(label)})' : ''}',
      ),
      // Universal web fallback.
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$latitude,$longitude',
      ),
    ];

    for (final uri in candidates) {
      if (await canLaunchUrl(uri)) {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    }
    return false;
  }
}
