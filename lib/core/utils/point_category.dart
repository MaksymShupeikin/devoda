import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// The kinds of points the map shows, plus a fallback.
///
/// Water points are categorised by their OSM `amenity` value:
///   * `drinking_water` -> Бювет (drinking fountain)
///   * `water_point`    -> Водокачка (water pump)
///
/// Resilience points ("Пункти незламності") come from a separate table and are
/// always [PointCategory.resilience].
enum PointCategory { drinkingWater, waterPoint, resilience, other }

extension PointCategoryX on PointCategory {
  /// OSM amenity values that map to each water category.
  static const Map<PointCategory, List<String>> _amenities = {
    PointCategory.drinkingWater: ['drinking_water'],
    PointCategory.waterPoint: ['water_point'],
  };

  /// Resolves a water category from a raw amenity/type string from Supabase.
  static PointCategory fromAmenity(String? raw) {
    if (raw == null) return PointCategory.other;
    final value = raw.trim().toLowerCase();
    for (final entry in _amenities.entries) {
      if (entry.value.contains(value)) return entry.key;
    }
    return PointCategory.other;
  }

  /// The canonical amenity string used when creating a new water point.
  String get amenityValue => switch (this) {
    PointCategory.drinkingWater => 'drinking_water',
    PointCategory.waterPoint => 'water_point',
    PointCategory.resilience => 'resilience',
    PointCategory.other => 'drinking_water',
  };

  /// Stable id used for the registered Mapbox style image.
  String get markerImageId => 'marker-$name';

  /// Custom SVG icon used on markers and in the filter/cards. Tinted with
  /// [color] at render time (the SVG uses `currentColor`).
  String get svgAsset => switch (this) {
    PointCategory.drinkingWater => 'assets/icons/drinking_water.svg',
    PointCategory.waterPoint => 'assets/icons/water_point.svg',
    PointCategory.resilience => 'assets/icons/resilience.svg',
    PointCategory.other => 'assets/icons/drinking_water.svg',
  };

  String label(AppLocalizations l) => switch (this) {
    PointCategory.drinkingWater => l.isUk ? 'Бювет' : 'Drinking fountain',
    PointCategory.waterPoint => l.isUk ? 'Водокачка' : 'Water pump',
    PointCategory.resilience => l.isUk ? 'Пункт незламності' : 'Resilience point',
    PointCategory.other => l.isUk ? 'Джерело води' : 'Water source',
  };

  String description(AppLocalizations l) => switch (this) {
    PointCategory.drinkingWater => l.isUk
        ? 'Питний фонтанчик або бювет з безкоштовним та відкритим доступом.'
        : 'A drinking fountain with free and open access.',
    PointCategory.waterPoint => l.isUk
        ? 'Ручна колонка або свердловина з підземною водою для кожного.'
        : 'A hand pump or well with groundwater for everyone.',
    PointCategory.resilience => l.isUk
        ? 'Пункт незламності: тепло, світло, зарядка, вода та зв’язок.'
        : 'Resilience point: heat, light, charging, water and connection.',
    PointCategory.other => l.isUk
        ? 'Будь-яке інше перевірене місце з доступом до питної води.'
        : 'Any other verified place with drinking water.',
  };

  Color get color => switch (this) {
    PointCategory.drinkingWater => AppColors.categoryDrinkingWater,
    PointCategory.waterPoint => AppColors.categoryWaterPoint,
    PointCategory.resilience => AppColors.categoryResilience,
    PointCategory.other => AppColors.categoryOther,
  };

  /// Fallback Material glyph (outlined) used if the SVG fails to load.
  IconData get icon => switch (this) {
    PointCategory.drinkingWater => Icons.water_drop_outlined,
    PointCategory.waterPoint => Icons.water_outlined,
    PointCategory.resilience => Icons.health_and_safety_outlined,
    PointCategory.other => Icons.opacity_outlined,
  };

  /// Categories shown in the filter bar (the `other` bucket is internal only).
  static const List<PointCategory> selectable = [
    PointCategory.drinkingWater,
    PointCategory.waterPoint,
    PointCategory.resilience,
  ];

  /// Categories a user can create via the add-point flow (water only).
  static const List<PointCategory> addable = [
    PointCategory.drinkingWater,
    PointCategory.waterPoint,
  ];
}
