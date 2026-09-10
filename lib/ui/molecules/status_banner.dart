import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

enum StatusBannerVariant { info, warning, error, success }

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.variant = StatusBannerVariant.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final StatusBannerVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  static IconData _iconFor(StatusBannerVariant v) => switch (v) {
        StatusBannerVariant.info => Icons.info_outline,
        StatusBannerVariant.warning => Icons.warning_amber_outlined,
        StatusBannerVariant.error => Icons.error_outline,
        StatusBannerVariant.success => Icons.check_circle_outline,
      };

  static Color _bgFor(AppColorsData colors, StatusBannerVariant v) => switch (v) {
        StatusBannerVariant.info => colors.statusInfoSubdued,
        StatusBannerVariant.warning => colors.statusWarningSubdued,
        StatusBannerVariant.error => colors.statusErrorSubdued,
        StatusBannerVariant.success => colors.statusSuccessSubdued,
      };

  static Color _fgFor(AppColorsData colors, StatusBannerVariant v) => switch (v) {
        StatusBannerVariant.info => colors.statusInfo,
        StatusBannerVariant.warning => colors.statusWarning,
        StatusBannerVariant.error => colors.statusError,
        StatusBannerVariant.success => colors.statusSuccess,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = _fgFor(colors, variant);
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _bgFor(colors, variant),
        borderRadius: AppRadius.borderCard,
      ),
      child: Row(
        children: [
          AppIcon(_iconFor(variant), color: fg, size: 20.0),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              message,
              style: AppTypography.bodySm,
              color: fg,
            ),
          ),
          if (hasAction) ...[
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: actionLabel!,
              variant: AppButtonVariant.ghost,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
