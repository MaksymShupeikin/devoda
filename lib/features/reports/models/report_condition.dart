import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Predefined point conditions a user can report. The [value] is what gets
/// stored in `report.reported_condition`; everything else is for the UI.
///
/// Kept simple and visual so non-experienced users can pick a state in one tap.
enum ReportCondition { working, noWater, badQuality, broken, dirty, noAccess }

extension ReportConditionX on ReportCondition {
  /// Stored text value.
  String get value => switch (this) {
    ReportCondition.working => 'working',
    ReportCondition.noWater => 'no_water',
    ReportCondition.badQuality => 'bad_quality',
    ReportCondition.broken => 'broken',
    ReportCondition.dirty => 'dirty',
    ReportCondition.noAccess => 'no_access',
  };

  String label(AppLocalizations l) => switch (this) {
    ReportCondition.working => l.isUk ? 'Все працює' : 'Working',
    ReportCondition.noWater => l.isUk ? 'Немає води' : 'No water',
    ReportCondition.badQuality => l.isUk ? 'Погана якість' : 'Poor quality',
    ReportCondition.broken => l.isUk ? 'Зламано' : 'Broken',
    ReportCondition.dirty => l.isUk ? 'Брудно' : 'Dirty',
    ReportCondition.noAccess => l.isUk ? 'Немає доступу' : 'No access',
  };

  IconData get icon => switch (this) {
    ReportCondition.working => Icons.check_circle_outline_rounded,
    ReportCondition.noWater => Icons.water_drop_outlined,
    ReportCondition.badQuality => Icons.science_outlined,
    ReportCondition.broken => Icons.build_outlined,
    ReportCondition.dirty => Icons.cleaning_services_outlined,
    ReportCondition.noAccess => Icons.block_outlined,
  };

  /// Green for "all good", amber/red for problems.
  Color get color => switch (this) {
    ReportCondition.working => AppColors.success,
    ReportCondition.noWater => AppColors.warning,
    ReportCondition.badQuality => AppColors.warning,
    ReportCondition.broken => AppColors.danger,
    ReportCondition.dirty => AppColors.warning,
    ReportCondition.noAccess => AppColors.danger,
  };

  static const List<ReportCondition> all = ReportCondition.values;

  /// Resolves a stored value back to a condition (null if unknown).
  static ReportCondition? fromValue(String? value) {
    if (value == null) return null;
    for (final c in ReportCondition.values) {
      if (c.value == value) return c;
    }
    return null;
  }

  /// Human label for an arbitrary stored value (falls back to the raw text).
  static String labelForValue(String value, AppLocalizations l) =>
      fromValue(value)?.label(l) ?? value;
}
