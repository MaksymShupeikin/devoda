import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The three kinds of water points the app deals with, plus a fallback.
///
/// Categorisation is driven by the OSM `amenity` value stored on each point:
///   * `drinking_water`  -> Бьювет (drinking fountain)
///   * `water_point`     -> Водокачка (water pump)
///   * `vending_machine` -> Автомат с водой (water vending machine)
///
/// All amenity <-> category mapping lives here so it can be changed in one
/// place if the dataset uses different strings.
enum WaterCategory {
  drinkingWater,
  waterPoint,
  vending,
  other,
}

extension WaterCategoryX on WaterCategory {
  /// OSM amenity values that map to each category.
  static const Map<WaterCategory, List<String>> _amenities = {
    WaterCategory.drinkingWater: ['drinking_water'],
    WaterCategory.waterPoint: ['water_point'],
    WaterCategory.vending: ['vending_machine', 'water_vending'],
  };

  /// Resolves a category from a raw amenity/type string coming from Supabase.
  static WaterCategory fromAmenity(String? raw) {
    if (raw == null) return WaterCategory.other;
    final value = raw.trim().toLowerCase();
    for (final entry in _amenities.entries) {
      if (entry.value.contains(value)) return entry.key;
    }
    return WaterCategory.other;
  }

  /// The canonical amenity string used when creating a new point.
  String get amenityValue => switch (this) {
        WaterCategory.drinkingWater => 'drinking_water',
        WaterCategory.waterPoint => 'water_point',
        WaterCategory.vending => 'vending_machine',
        WaterCategory.other => 'drinking_water',
      };

  /// Stable id used for the registered Mapbox style image.
  String get markerImageId => 'marker-$name';

  String get label => switch (this) {
        WaterCategory.drinkingWater => 'Бьювет',
        WaterCategory.waterPoint => 'Водокачка',
        WaterCategory.vending => 'Автомат с водой',
        WaterCategory.other => 'Источник воды',
      };

  String get description => switch (this) {
        WaterCategory.drinkingWater =>
          'Питьевой фонтанчик или бьювет с открытым доступом к воде.',
        WaterCategory.waterPoint =>
          'Водокачка или колонка с питьевой водой.',
        WaterCategory.vending =>
          'Автомат, где можно набрать воду в свою тару.',
        WaterCategory.other => 'Точка с питьевой водой.',
      };

  Color get color => switch (this) {
        WaterCategory.drinkingWater => AppColors.categoryDrinkingWater,
        WaterCategory.waterPoint => AppColors.categoryWaterPoint,
        WaterCategory.vending => AppColors.categoryVending,
        WaterCategory.other => AppColors.categoryOther,
      };

  IconData get icon => switch (this) {
        WaterCategory.drinkingWater => Icons.water_drop_rounded,
        WaterCategory.waterPoint => Icons.water_rounded,
        WaterCategory.vending => Icons.local_drink_rounded,
        WaterCategory.other => Icons.opacity_rounded,
      };

  /// Categories shown to the user (the `other` bucket is internal only).
  static const List<WaterCategory> selectable = [
    WaterCategory.drinkingWater,
    WaterCategory.waterPoint,
    WaterCategory.vending,
  ];
}
