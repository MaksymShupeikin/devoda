import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Shown while the user is choosing a location for a new point. A fixed
/// crosshair marks the map center (easier than precise tapping), with a hint
/// banner and confirm/cancel actions.
class PlacementOverlay extends StatelessWidget {
  const PlacementOverlay({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hint banner.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Подвиньте карту так, чтобы метка указывала на нужное место',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Fixed center crosshair (its tip points to the map center).
        const Center(
          child: Padding(
            // Offset upward so the pin tip — not its middle — sits on center.
            padding: EdgeInsets.only(bottom: 48),
            child: Icon(
              Icons.location_on,
              size: 64,
              color: AppColors.primary,
              shadows: [
                Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
          ),
        ),

        // Confirm / cancel bar.
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Text(
                          'Метка указывает на новое место?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      AppButton(
                        label: 'Поставить здесь',
                        icon: Icons.check_circle_rounded,
                        onPressed: onConfirm,
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'Отмена',
                        variant: AppButtonVariant.secondary,
                        onPressed: onCancel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
