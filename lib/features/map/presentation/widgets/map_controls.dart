import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
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
    this.onAccount,
    this.onLanguageToggle,
    this.currentLanguageCode,
  });

  final VoidCallback onLocate;
  final VoidCallback onRefresh;
  final VoidCallback onOffline;
  final VoidCallback onAdd;

  /// Shown only when the user is signed in (opens the account sheet).
  final VoidCallback? onAccount;

  /// Toggles the application locale.
  final VoidCallback? onLanguageToggle;

  /// The active language code (e.g. "UK" or "EN") to display.
  final String? currentLanguageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (onAccount != null) ...[
          _RoundButton(
            icon: Icons.person_outline_rounded,
            tooltip: context.l10n.account,
            onTap: onAccount!,
          ),
          const SizedBox(height: 14),
        ] else if (onLanguageToggle != null && currentLanguageCode != null) ...[
          _LanguageButton(
            languageCode: currentLanguageCode!,
            onTap: onLanguageToggle!,
          ),
          const SizedBox(height: 14),
        ],
        _RoundButton(
          icon: Icons.download_outlined,
          tooltip: context.l10n.downloadOfflineMap,
          onTap: onOffline,
        ),
        const SizedBox(height: 14),
        _RoundButton(
          icon: Icons.refresh,
          tooltip: context.l10n.refresh,
          onTap: onRefresh,
        ),
        const SizedBox(height: 14),
        _RoundButton(
          icon: Icons.my_location_outlined,
          tooltip: context.l10n.whereAmI,
          onTap: onLocate,
        ),
        const SizedBox(height: 18),
        // The primary action — large and labelled for clarity.
        _AddButton(onTap: onAdd),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.languageCode, required this.onTap});

  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Змінити мову / Change language',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
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
              child: Text(
                languageCode,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
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
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
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
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
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
                const Icon(
                  Icons.add_location_alt_outlined,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.add,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
