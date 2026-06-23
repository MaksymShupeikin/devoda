import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Unified entry point for bottom sheets. Centralises wrapping, safe-area
/// padding, the drag handle and rounded styling so every sheet looks the same.
class AppModal {
  AppModal._();

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    // Set to 0 for full-bleed content (the sheet adds its own padding).
    double horizontalPadding = 20,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: AppColors.surface,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            // Tapping anywhere on the sheet (outside a field) dismisses the
            // keyboard / drops focus.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _DragHandle(),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        4,
                        horizontalPadding,
                        20,
                      ),
                      child: builder(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 6,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
