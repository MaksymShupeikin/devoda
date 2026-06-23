import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/point_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/app_modal.dart';

/// Result returned from the add-point form.
class AddPointResult {
  const AddPointResult({required this.category, this.name});

  final PointCategory category;
  final String? name;
}

/// Form for describing a new water point (type + optional name).
///
/// Submission is currently a mock: the point is added locally and cached.
/// Real submission (tied to phone-number auth) will be wired in later.
class AddPointSheet extends StatefulWidget {
  const AddPointSheet({super.key});

  static Future<AddPointResult?> show(BuildContext context) {
    return AppModal.showBottomSheet<AddPointResult>(
      context: context,
      builder: (_) => const AddPointSheet(),
    );
  }

  @override
  State<AddPointSheet> createState() => _AddPointSheetState();
}

class _AddPointSheetState extends State<AddPointSheet> {
  PointCategory _category = PointCategory.drinkingWater;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      AddPointResult(category: _category, name: name.isEmpty ? null : name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.newWaterPoint, style: AppTextStyles.title),
          const SizedBox(height: 24),
          Text(context.l10n.whichType, style: AppTextStyles.label),
          const SizedBox(height: 12),
          ...PointCategoryX.addable.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryOption(
                category: category,
                selected: _category == category,
                onTap: () => setState(() => _category = category),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(context.l10n.nameOptional, style: AppTextStyles.label),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: AppTextStyles.body,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.l10n.nameHint,
              hintStyle: AppTextStyles.bodyMuted,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: context.l10n.savePoint,
            icon: Icons.save_outlined,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final PointCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Material(
      color: selected ? color.withValues(alpha: 0.10) : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: CategoryIcon(
                    category: category,
                    size: 30,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.label(context.l10n), style: AppTextStyles.subtitle),
                    const SizedBox(height: 2),
                    Text(
                      category.description(context.l10n),
                      style: AppTextStyles.bodyMuted.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? color : AppColors.border,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
