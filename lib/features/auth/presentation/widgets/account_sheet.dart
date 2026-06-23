import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/utils/ua_phone_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../services/auth_service.dart';

/// Shows the signed-in phone number, a language switcher and a sign-out button.
class AccountSheet extends ConsumerWidget {
  const AccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppModal.showBottomSheet<void>(
      context: context,
      builder: (_) => const AccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final phone = UaPhone.displayE164(ref.watch(currentUserPhoneProvider));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.signedInAs, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    phone.isEmpty ? l10n.unknownNumber : phone,
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _LanguageSwitcher(),
        const SizedBox(height: 20),
        AppButton(
          label: l10n.signOut,
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: () => _signOut(context, ref),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: l10n.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    await ref.read(authServiceProvider).signOut();
    navigator.pop();
    AppNotify.info(l10n.signedOutMessage);
  }
}

/// Segmented UK / EN language switcher.
class _LanguageSwitcher extends ConsumerWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeControllerProvider).languageCode;
    final notifier = ref.read(localeControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.language, style: AppTextStyles.label),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _LangSegment(
                // Language names stay in their own language.
                label: 'Українська',
                selected: code == 'uk',
                onTap: () => notifier.setLocale(const Locale('uk')),
              ),
              const SizedBox(width: 4),
              _LangSegment(
                label: 'English',
                selected: code == 'en',
                onTap: () => notifier.setLocale(const Locale('en')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LangSegment extends StatelessWidget {
  const _LangSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
