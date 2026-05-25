import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.interactivePrimary,
        borderRadius: AppRadius.borderInput,
      ),
      child: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: textColor ?? AppColors.interactivePrimaryForeground,
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'default', wrapper: previewWrapper)
Widget previewAppBadgeDefault() => const AppBadge(label: '42');

@Preview(name: 'error', wrapper: previewWrapper)
Widget previewAppBadgeError() => const AppBadge(
      label: 'Error',
      backgroundColor: AppColors.statusError,
      textColor: AppColors.surface,
    );

@Preview(name: 'success', wrapper: previewWrapper)
Widget previewAppBadgeSuccess() => const AppBadge(
      label: 'Done',
      backgroundColor: AppColors.statusSuccess,
      textColor: AppColors.surface,
    );
