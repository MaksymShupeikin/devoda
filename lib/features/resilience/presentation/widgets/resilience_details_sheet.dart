import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/map_navigation.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../models/resilience_point.dart';

/// Details for a resilience point ("Пункт незламності"): available services
/// and a big button to navigate there.
class ResilienceDetailsSheet extends StatelessWidget {
  const ResilienceDetailsSheet({super.key, required this.point});

  final ResiliencePoint point;

  static Future<void> show(BuildContext context, ResiliencePoint point) {
    return AppModal.showBottomSheet<void>(
      context: context,
      builder: (_) => ResilienceDetailsSheet(point: point),
    );
  }

  /// Treats a raw service value as "available" unless it is clearly negative.
  static bool _has(String? raw) {
    if (raw == null) return false;
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return false;
    const negatives = {'0', 'ні', 'нет', 'no', 'false', '-', 'немає', 'нема'};
    return !negatives.contains(v);
  }

  @override
  Widget build(BuildContext context) {
    const color = AppColors.categoryResilience;
    final services = <_Service>[
      _Service(Icons.local_fire_department_outlined, context.l10n.svcHeat, point.heating),
      _Service(Icons.bolt_outlined, context.l10n.svcGenerator, point.generator),
      _Service(Icons.battery_charging_full_outlined, context.l10n.svcCharging, point.charging),
      _Service(Icons.water_drop_outlined, context.l10n.svcWater, point.water),
      _Service(Icons.wifi_outlined, context.l10n.svcInternet, point.internet),
      _Service(Icons.cell_tower_outlined, context.l10n.svcConnection, point.mobileConnection),
      _Service(Icons.medical_services_outlined, context.l10n.svcFirstAid, point.firstAid),
      _Service(Icons.accessible_outlined, context.l10n.accessibility, point.accessibility),
    ].where((s) => _has(s.value)).toList();

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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CategoryIcon(
                  category: PointCategory.resilience,
                  size: 32,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.title(context.l10n), style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(PointCategory.resilience.label(context.l10n), style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
          ],
        ),
        if (point.locationLine != null) ...[
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.place_outlined,
                size: 26,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(point.locationLine!, style: AppTextStyles.body),
              ),
            ],
          ),
        ],
        if (services.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(context.l10n.availableServices, style: AppTextStyles.label),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: services
                .map((s) => _ServiceChip(icon: s.icon, label: s.label))
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: context.l10n.buildRoute,
          icon: Icons.directions_outlined,
          onPressed: () => _navigate(context),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: context.l10n.close,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _navigate(BuildContext context) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    if (!point.hasCoordinates) return;
    final ok = await MapNavigation.navigateTo(
      latitude: point.latitude!,
      longitude: point.longitude!,
      label: point.title(l10n),
    );
    navigator.pop();
    if (!ok) {
      AppNotify.error(l10n.cantOpenMaps);
    }
  }
}

class _Service {
  const _Service(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String? value;
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.categoryResilience.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.categoryResilience),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 17,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
