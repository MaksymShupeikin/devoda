import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/offline_map_service.dart';

/// Immutable state for the offline-area download flow.
class OfflineDownloadState {
  const OfflineDownloadState({
    this.inProgress = false,
    this.progress = 0,
    this.completed = false,
    this.error,
  });

  final bool inProgress;
  final double progress;
  final bool completed;
  final String? error;

  static const OfflineDownloadState initial = OfflineDownloadState();

  OfflineDownloadState copyWith({
    bool? inProgress,
    double? progress,
    bool? completed,
    String? error,
  }) {
    return OfflineDownloadState(
      inProgress: inProgress ?? this.inProgress,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineDownloadState &&
        other.inProgress == inProgress &&
        other.progress == progress &&
        other.completed == completed &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(inProgress, progress, completed, error);

  @override
  String toString() =>
      'OfflineDownloadState(inProgress: $inProgress, progress: $progress, '
      'completed: $completed, error: $error)';
}

class OfflineDownloadController extends Notifier<OfflineDownloadState> {
  @override
  OfflineDownloadState build() => OfflineDownloadState.initial;

  Future<void> download({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    if (state.inProgress) return;
    state = const OfflineDownloadState(inProgress: true, progress: 0);
    try {
      await ref
          .read(offlineMapServiceProvider)
          .downloadAround(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            onProgress: (p) {
              state = state.copyWith(progress: p);
            },
          );
      state = const OfflineDownloadState(completed: true, progress: 1);
    } catch (e) {
      state = OfflineDownloadState(error: e.toString());
    }
  }

  void reset() => state = OfflineDownloadState.initial;
}

final offlineDownloadControllerProvider =
    NotifierProvider<OfflineDownloadController, OfflineDownloadState>(
      OfflineDownloadController.new,
    );
