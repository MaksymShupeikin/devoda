import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      builder: (_) => OfflineDownloadSheet(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  ConsumerState<OfflineDownloadSheet> createState() =>
      _OfflineDownloadSheetState();
}

class _OfflineDownloadSheetState extends ConsumerState<OfflineDownloadSheet> {
  double _radiusKm = 5;

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
            const Icon(Icons.download_for_offline_rounded,
                color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Карта без интернета', style: AppTextStyles.title),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Скачайте карту вокруг этого места, чтобы пользоваться приложением '
          'без интернета. Метки уже сохраняются автоматически.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 18),
        Text('Радиус: ${_radiusKm.round()} км', style: AppTextStyles.subtitle),
        Slider(
          value: _radiusKm,
          min: 2,
          max: 15,
          divisions: 13,
          activeColor: AppColors.primary,
          label: '${_radiusKm.round()} км',
          onChanged: state.inProgress
              ? null
              : (value) => setState(() => _radiusKm = value),
        ),
        const SizedBox(height: 8),
        if (state.inProgress) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress == 0 ? null : state.progress,
              minHeight: 14,
              backgroundColor: AppColors.surfaceMuted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Скачивание… ${(state.progress * 100).round()}%',
            style: AppTextStyles.body,
          ),
        ] else if (state.completed) ...[
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Готово! Карта сохранена для офлайн-доступа.',
                  style: AppTextStyles.body.copyWith(color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Закрыть',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ] else ...[
          if (state.error != null) ...[
            Text(
              'Не удалось скачать. Проверьте интернет и попробуйте снова.',
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Скачать карту',
            icon: Icons.cloud_download_rounded,
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
