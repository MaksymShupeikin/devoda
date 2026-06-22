import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/water_category.dart';
import '../../controllers/water_points_controller.dart';

/// Horizontal row of large, tappable category chips that filter the markers.
class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mapFilterControllerProvider);
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: WaterCategoryX.selectable.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = WaterCategoryX.selectable[index];
          return _CategoryChip(
            category: category,
            active: selected.contains(category),
            onTap: () => ref
                .read(mapFilterControllerProvider.notifier)
                .toggle(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final WaterCategory category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Material(
      color: active ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: active ? color : AppColors.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 24,
                color: active ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 17,
                  color: active ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
