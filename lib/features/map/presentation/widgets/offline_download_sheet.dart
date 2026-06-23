import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../controllers/offline_download_controller.dart';

/// Lets the user download the current map area (tiles + markers cache) for
/// offline use. Markers themselves are already cached by the points
/// controller; this downloads the Mapbox tiles around the chosen center.
class OfflineDownloadSheet extends ConsumerStatefulWidget {
  const OfflineDownloadSheet({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  static Future<void> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
  }) {
    return AppModal.showBottomSheet<void>(
      context: context,
      isDismissible: true,
      builder: (_) =>
          OfflineDownloadSheet(latitude: latitude, longitude: longitude),
    );
  }

  @override
  ConsumerState<OfflineDownloadSheet> createState() =>
      _OfflineDownloadSheetState();
}

class _OfflineDownloadSheetState extends ConsumerState<OfflineDownloadSheet> {
  double _radiusKm = 3;

  @override
  void initState() {
    super.initState();
    // Start each visit from a clean state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlineDownloadControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offlineDownloadControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map_outlined,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.offlineTitle, style: AppTextStyles.title),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.offlineDesc,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 24),
        Text(context.l10n.radiusValue(_radiusKm.round()), style: AppTextStyles.subtitle),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: const _EdgeToEdgeTrackShape(),
            // No extra outer padding, so the track lines up with the text/button.
            padding: EdgeInsets.zero,
          ),
          child: Slider(
            value: _radiusKm,
            min: 1,
            max: 8,
            divisions: 7,
            activeColor: AppColors.primary,
            onChanged: state.inProgress
                ? null
                : (value) => setState(() => _radiusKm = value),
          ),
        ),
        const SizedBox(height: 24),
        if (state.inProgress) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress == 0 ? null : state.progress,
              minHeight: 14,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.downloadingPct((state.progress * 100).round()),
            style: AppTextStyles.body,
          ),
        ] else if (state.completed) ...[
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.offlineDone,
                  style: AppTextStyles.body.copyWith(color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: context.l10n.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ] else ...[
          if (state.error != null) ...[
            Text(
              context.l10n.downloadFailed,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 16),
          ],
          AppButton(
            label: context.l10n.downloadMap,
            icon: Icons.cloud_download_outlined,
            onPressed: () => ref
                .read(offlineDownloadControllerProvider.notifier)
                .download(
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  radiusKm: _radiusKm,
                ),
          ),
        ],
      ],
    );
  }
}

/// Slider track shape that spans the full available width, so the track lines
/// up with the surrounding edge-to-edge text and buttons (the default shape
/// insets the track by the thumb/overlay radius).
class _EdgeToEdgeTrackShape extends RoundedRectSliderTrackShape {
  const _EdgeToEdgeTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }
}
