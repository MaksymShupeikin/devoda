import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Stacked control buttons on the right edge of the map.
class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.onLocate,
    required this.onRefresh,
    required this.onOffline,
    required this.onAdd,
  });

  final VoidCallback onLocate;
  final VoidCallback onRefresh;
  final VoidCallback onOffline;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _RoundButton(
          icon: Icons.download_for_offline_rounded,
          tooltip: 'Скачать офлайн-карту',
          onTap: onOffline,
        ),
        const SizedBox(height: 14),
        _RoundButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Обновить',
          onTap: onRefresh,
        ),
        const SizedBox(height: 14),
        _RoundButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Где я',
          onTap: onLocate,
        ),
        const SizedBox(height: 18),
        // The primary action — large and labelled for clarity.
        _AddButton(onTap: onAdd),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_location_alt_rounded,
                  size: 30, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Добавить',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
