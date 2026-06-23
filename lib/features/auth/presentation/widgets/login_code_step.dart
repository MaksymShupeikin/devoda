import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../controllers/login_controller.dart';

/// Second step: enter the 6-digit SMS code.
class LoginCodeStep extends StatelessWidget {
  const LoginCodeStep({
    super.key,
    required this.controller,
    required this.state,
    required this.onChanged,
    required this.onVerify,
    required this.onResend,
    required this.onEditPhone,
  });

  final TextEditingController controller;
  final LoginState state;
  final ValueChanged<String> onChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onEditPhone;

  @override
  Widget build(BuildContext context) {
    final canVerify = controller.text.trim().length == 6 && !state.submitting;

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
            Icons.sms_outlined,
            size: 38,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 22),
        Text(context.l10n.codeTitle, style: AppTextStyles.display),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: AppTextStyles.bodyMuted,
            children: [
              TextSpan(text: context.l10n.codeSentTo),
              TextSpan(
                text: state.e164Phone,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(context.l10n.codeLabel, style: AppTextStyles.label),
        const SizedBox(height: 10),
        Pinput(
          length: 6,
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          defaultPinTheme: PinTheme(
            width: 46,
            height: 54,
            textStyle: AppTextStyles.display.copyWith(
              fontSize: 22,
              letterSpacing: 0,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 46,
            height: 54,
            textStyle: AppTextStyles.display.copyWith(
              fontSize: 22,
              letterSpacing: 0,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
          ),
          submittedPinTheme: PinTheme(
            width: 46,
            height: 54,
            textStyle: AppTextStyles.display.copyWith(
              fontSize: 22,
              letterSpacing: 0,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
          ),
          onCompleted: (_) => canVerify ? onVerify() : null,
        ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Text(
            state.error!,
            style: AppTextStyles.body.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: context.l10n.confirm,
          icon: Icons.check_rounded,
          busy: state.submitting,
          onPressed: canVerify ? onVerify : null,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton(
              onPressed: state.submitting ? null : onEditPhone,
              child: Text(
                context.l10n.changeNumber,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: state.submitting ? null : onResend,
              child: Text(
                context.l10n.resend,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
