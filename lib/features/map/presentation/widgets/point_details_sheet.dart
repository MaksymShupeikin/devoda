import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/map_navigation.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../models/water_point.dart';
import '../../../reports/presentation/widgets/report_section.dart';

class PointDetailsSheet extends StatelessWidget {
  const PointDetailsSheet({super.key, required this.point});

  final WaterPoint point;

  /// Inset re-added internally so the condition chips can scroll full-bleed.
  static const double _inset = 20;

  static Future<void> show(BuildContext context, WaterPoint point) {
    return AppModal.showBottomSheet<void>(
      context: context,
      horizontalPadding: 0,
      builder: (_) => PointDetailsSheet(point: point),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = point.category;
    final maxHeight = MediaQuery.of(context).size.height * 0.82;
    final infoRows = _buildInfoRows(context);
    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              // Room so the last content isn't hidden behind the pinned bar.
              padding: const EdgeInsets.only(bottom: 172),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padded content (everything except the full-bleed chips).
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _inset),
                    child: Column(
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
                              child: Center(
                                child: CategoryIcon(
                                  category: category,
                                  size: 32,
                                  color: category.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    point.title(context.l10n),
                                    style: AppTextStyles.title,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    category.label(context.l10n),
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ...infoRows,
                        // Breathing room only when there are no info rows — with
                        // data present the divider's own top space is enough, so
                        // the last row sits closer to the separator line.
                        if (infoRows.isEmpty) const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // Condition selector (full-bleed) + reports history.
                  if (point.id > 0)
                    ReportSection(pointId: point.id, horizontalInset: _inset),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PinnedActions(
              onNavigate: () => _navigate(context),
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the info rows, including only those whose data is present.
  List<Widget> _buildInfoRows(BuildContext context) {
    final l10n = context.l10n;
    final rows = <Widget>[];

    final accessibility = _yesNo(point.wheelchair, l10n, yes: l10n.hasRamp);
    if (accessibility != null) {
      rows.add(
        _InfoRow(
          icon: Icons.accessible_outlined,
          label: l10n.accessibility,
          value: accessibility,
        ),
      );
    }

    final fee = _fee(point.fee, l10n);
    if (fee != null) {
      rows.add(
        _InfoRow(
          icon: Icons.payments_outlined,
          label: l10n.payment,
          value: fee,
        ),
      );
    }

    final access = _access(point.access, l10n);
    if (access != null) {
      rows.add(
        _InfoRow(
          icon: Icons.lock_open_outlined,
          label: l10n.accessLabel,
          value: access,
        ),
      );
    }

    if (point.openingHours != null && point.openingHours!.isNotEmpty) {
      rows.add(
        _InfoRow(
          icon: Icons.schedule_outlined,
          label: l10n.openingHours,
          value: point.openingHours!,
        ),
      );
    }

    if (rows.isEmpty) return rows;
    return [const SizedBox(height: 24), ...rows];
  }

  Future<void> _navigate(BuildContext context) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final ok = await MapNavigation.navigateTo(
      latitude: point.latitude,
      longitude: point.longitude,
      label: point.title(l10n),
    );
    navigator.pop();
    if (!ok) {
      AppNotify.error(l10n.cantOpenMaps);
    }
  }

  static String? _yesNo(
    String? raw,
    AppLocalizations l, {
    required String yes,
  }) {
    if (raw == null || raw.isEmpty) return null;
    return raw.toLowerCase() == 'yes' ? yes : l.no;
  }

  static String? _fee(String? raw, AppLocalizations l) {
    switch (raw?.toLowerCase()) {
      case 'yes':
        return l.paid;
      case 'no':
        return l.free;
      default:
        return null;
    }
  }

  static String? _access(String? raw, AppLocalizations l) {
    switch (raw?.toLowerCase()) {
      case 'yes':
      case 'public':
      case 'permissive':
        return l.accessFree;
      case 'private':
        return l.accessPrivate;
      case 'customers':
        return l.accessCustomers;
      default:
        return null;
    }
  }
}

/// Bottom-pinned action buttons with a white gradient fade so the scrolling
/// content disappears smoothly underneath them.
class _PinnedActions extends StatelessWidget {
  const _PinnedActions({required this.onNavigate, required this.onClose});

  final VoidCallback onNavigate;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IgnorePointer(
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface.withValues(alpha: 0),
                  AppColors.surface,
                ],
              ),
            ),
          ),
        ),
        ColoredBox(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AppButton(
                  label: context.l10n.buildRoute,
                  icon: Icons.directions_outlined,
                  onPressed: onNavigate,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: context.l10n.close,
                  variant: AppButtonVariant.secondary,
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
