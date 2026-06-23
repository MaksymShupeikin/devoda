import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/preferences_service.dart';

/// Client-side throttle: limits how often a single signed-in user can add a
/// new point, to discourage spamming. (For hard guarantees this should be
/// backed by a server-side rule too — see README.)
class AddRateLimiter {
  AddRateLimiter(this._prefs);

  final SharedPreferences _prefs;

  /// Minimum time between two additions by the same user.
  static const Duration cooldown = Duration(minutes: 2);

  String _key(String userId) => 'last_add_at_$userId';

  /// Remaining cooldown for [userId], or null if they may add right now.
  Duration? remaining(String userId) {
    final millis = _prefs.getInt(_key(userId));
    if (millis == null) return null;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(millis),
    );
    final left = cooldown - elapsed;
    return left.isNegative ? null : left;
  }

  /// Records that [userId] just added a point.
  Future<void> markUsed(String userId) async {
    await _prefs.setInt(_key(userId), DateTime.now().millisecondsSinceEpoch);
  }
}

final addRateLimiterProvider = Provider<AddRateLimiter>((ref) {
  return AddRateLimiter(ref.watch(sharedPreferencesProvider));
});
