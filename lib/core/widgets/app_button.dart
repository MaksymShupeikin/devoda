import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Large, high-contrast primary/secondary button tuned for older users.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.busy = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool busy;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;
    final Color background =
        isPrimary ? AppColors.primary : AppColors.surface;
    final Color foreground =
        isPrimary ? AppColors.textOnPrimary : AppColors.primary;

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 26, color: foreground),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(color: foreground),
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 62,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        elevation: isPrimary ? 1 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.25),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: busy ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.primary, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary }
