import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ua_phone_formatter.dart';
import '../../../../core/utils/app_notify.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../controllers/login_controller.dart';
import '../widgets/login_code_step.dart';
import '../widgets/login_phone_step.dart';

/// Phone + OTP registration screen. Opened when an unauthenticated user tries
/// to add a point. Pops with `true` once the user is signed in.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const String path = '/login';
  static const String name = 'login';

  static GoRoute get route => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const LoginPage(),
  );

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!UaPhone.isComplete(_phoneController.text)) return;
    FocusScope.of(context).unfocus();
    ref
        .read(loginControllerProvider.notifier)
        .sendCode(UaPhone.toE164(_phoneController.text));
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) return;
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(loginControllerProvider.notifier)
        .verifyCode(code);
    if (ok && mounted) {
      AppNotify.success(context.l10n.signedInMessage, title: context.l10n.welcome);
      context.pop(true);
    }
  }

  void _editPhone() {
    _codeController.clear();
    ref.read(loginControllerProvider.notifier).editPhone();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isCode = state.step == LoginStep.code;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 28),
              onPressed: () => isCode ? _editPhone() : context.pop(false),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: isCode
              ? LoginCodeStep(
                  controller: _codeController,
                  state: state,
                  onChanged: (_) => setState(() {}),
                  onVerify: _verify,
                  onResend: _sendCode,
                  onEditPhone: _editPhone,
                )
              : LoginPhoneStep(
                  controller: _phoneController,
                  state: state,
                  onChanged: (_) => setState(() {}),
                  onSubmit: _sendCode,
                ),
        ),
      ),
    );
  }
}

/// Shared input decoration for the auth fields.
InputDecoration authFieldDecoration({String? hintText, String? prefixText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.bodyMuted,
    prefixText: prefixText,
    prefixStyle: AppTextStyles.subtitle,
    filled: true,
    fillColor: AppColors.surfaceMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}
