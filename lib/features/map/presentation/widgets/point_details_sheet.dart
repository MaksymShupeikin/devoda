import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/map_navigation.dart';
import '../../../../core/utils/water_category.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../models/water_point.dart';

/// Details for a single water point, with a big "navigate" button that opens
/// the device's default maps app.
class PointDetailsSheet extends StatelessWidget {
  const PointDetailsSheet({super.key, required this.point});

  final WaterPoint point;

  static Future<void> show(BuildContext context, WaterPoint point) {
    return AppModal.showBottomSheet<void>(
      context: context,
      builder: (_) => PointDetailsSheet(point: point),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = point.category;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(category.icon, color: category.color, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.displayName, style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(category.label, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _InfoRow(
          icon: Icons.accessible_rounded,
          label: 'Доступность',
          value: _yesNo(point.wheelchair, yes: 'Есть пандус/доступ'),
        ),
        _InfoRow(
          icon: Icons.payments_rounded,
          label: 'Оплата',
          value: _fee(point.fee),
        ),
        _InfoRow(
          icon: Icons.lock_open_rounded,
          label: 'Доступ',
          value: _access(point.access),
        ),
        if (point.openingHours != null && point.openingHours!.isNotEmpty)
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Часы работы',
            value: point.openingHours!,
          ),
        const SizedBox(height: 22),
        AppButton(
          label: 'Проложить маршрут',
          icon: Icons.directions_rounded,
          onPressed: () => _navigate(context),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Закрыть',
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _navigate(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await MapNavigation.navigateTo(
      latitude: point.latitude,
      longitude: point.longitude,
      label: point.displayName,
    );
    navigator.pop();
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось открыть приложение карт')),
      );
    }
  }

  static String _yesNo(String? raw, {required String yes}) {
    if (raw == null) return 'Нет данных';
    return raw.toLowerCase() == 'yes' ? yes : 'Нет';
  }

  static String _fee(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'yes':
        return 'Платно';
      case 'no':
        return 'Бесплатно';
      default:
        return 'Нет данных';
    }
  }

  static String _access(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'yes':
      case 'public':
      case 'permissive':
        return 'Свободный';
      case 'private':
        return 'Частный';
      case 'customers':
        return 'Для клиентов';
      default:
        return 'Нет данных';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
