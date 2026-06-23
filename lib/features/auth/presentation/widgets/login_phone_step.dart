import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ua_phone_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../controllers/login_controller.dart';
import '../pages/login_page.dart';

/// First step: enter the Ukrainian phone number (fixed `+380` prefix + mask).
class LoginPhoneStep extends StatelessWidget {
  const LoginPhoneStep({
    super.key,
    required this.controller,
    required this.state,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final LoginState state;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final canSubmit = UaPhone.isComplete(controller.text) && !state.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add_location_alt_outlined,
            size: 38,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          context.l10n.registerTitle,
          style: AppTextStyles.display,
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.phoneSubtitle,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 28),
        Text(context.l10n.phoneLabel, style: AppTextStyles.label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.subtitle,
          inputFormatters: [UaPhoneInputFormatter()],
          decoration: authFieldDecoration(
            prefixText: controller.text.startsWith('1')
                ? '+ '
                : '${UaPhone.prefix} ',
            hintText: controller.text.startsWith('1')
                ? '1 800 555 0123'
                : '00 000 00 00',
          ),
          onSubmitted: (_) => canSubmit ? onSubmit() : null,
        ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Text(
            state.error!,
            style: AppTextStyles.body.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 28),
        AppButton(
          label: context.l10n.getCode,
          icon: Icons.sms_outlined,
          busy: state.submitting,
          onPressed: canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}
