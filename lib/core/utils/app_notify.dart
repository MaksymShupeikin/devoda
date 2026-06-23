import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// App-wide, top-of-screen notifications (toasts) with a consistent, large and
/// high-contrast look. Backed by `toastification`; works without a
/// `BuildContext` because the app is wrapped in [ToastificationWrapper].
class AppNotify {
  AppNotify._();

  static void success(String message, {String? title}) => _show(
    message,
    title: title,
    type: ToastificationType.success,
    color: AppColors.success,
    icon: Icons.check_circle_outline_rounded,
  );

  static void error(String message, {String? title}) => _show(
    message,
    title: title,
    type: ToastificationType.error,
    color: AppColors.danger,
    icon: Icons.error_outline_rounded,
  );

  static void info(String message, {String? title}) => _show(
    message,
    title: title,
    type: ToastificationType.info,
    color: AppColors.primary,
    icon: Icons.info_outline_rounded,
  );

  static void _show(
    String message, {
    required ToastificationType type,
    required Color color,
    required IconData icon,
    String? title,
  }) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 250),
      primaryColor: color,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      borderRadius: BorderRadius.circular(18),
      showProgressBar: false,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      icon: Icon(icon, color: color, size: 30),
      title: title != null
          ? Text(title, style: AppTextStyles.subtitle)
          : null,
      description: Text(message, style: AppTextStyles.body),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A12222F),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
}
