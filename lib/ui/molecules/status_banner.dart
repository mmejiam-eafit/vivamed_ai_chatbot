import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

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

  static Color _bgFor(StatusBannerVariant v) => switch (v) {
        StatusBannerVariant.info => AppColors.statusInfoSubdued,
        StatusBannerVariant.warning => AppColors.statusWarningSubdued,
        StatusBannerVariant.error => AppColors.statusErrorSubdued,
        StatusBannerVariant.success => AppColors.statusSuccessSubdued,
      };

  static Color _fgFor(StatusBannerVariant v) => switch (v) {
        StatusBannerVariant.info => AppColors.statusInfo,
        StatusBannerVariant.warning => AppColors.statusWarning,
        StatusBannerVariant.error => AppColors.statusError,
        StatusBannerVariant.success => AppColors.statusSuccess,
      };

  @override
  Widget build(BuildContext context) {
    final fg = _fgFor(variant);
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _bgFor(variant),
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

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'info', size: Size(360, 56), wrapper: previewWrapper)
Widget previewStatusBannerInfo() =>
    const StatusBanner(message: 'AI analysis is running…');

@Preview(name: 'warning', size: Size(360, 56), wrapper: previewWrapper)
Widget previewStatusBannerWarning() => const StatusBanner(
      message: 'Low confidence — manual review recommended.',
      variant: StatusBannerVariant.warning,
    );

@Preview(name: 'error — with action', size: Size(360, 56), wrapper: previewWrapper)
Widget previewStatusBannerError() => StatusBanner(
      message: 'Upload failed.',
      variant: StatusBannerVariant.error,
      actionLabel: 'Retry',
      onAction: () {},
    );

@Preview(name: 'success', size: Size(360, 56), wrapper: previewWrapper)
Widget previewStatusBannerSuccess() => const StatusBanner(
      message: 'Report saved successfully.',
      variant: StatusBannerVariant.success,
    );
