import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../controllers/water_points_controller.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mapFilterControllerProvider);
    return SizedBox(
      height: 68,
      child: ListView.separated(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: PointCategoryX.selectable.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = PointCategoryX.selectable[index];
          return _CategoryChip(
            category: category,
            active: selected.contains(category),
            onTap: () =>
                ref.read(mapFilterControllerProvider.notifier).toggle(category),
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

  final PointCategory category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Container(
      decoration: BoxDecoration(
        color: active ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
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
                CategoryIcon(
                  category: category,
                  size: 26,
                  color: active ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  category.label(context.l10n),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 17,
                    color: active ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
