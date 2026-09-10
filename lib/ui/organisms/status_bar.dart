import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: AppElevation.raised,
      ),
      child: StatusBanner(
        message: message,
        variant: variant,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'info', size: Size(390, 56), wrapper: previewWrapper)
Widget previewStatusBarInfo() => const StatusBar(message: 'AI analysis is running…');

@Preview(name: 'warning', size: Size(390, 56), wrapper: previewWrapper)
Widget previewStatusBarWarning() => const StatusBar(
      message: 'Low confidence — manual review recommended.',
      variant: StatusBannerVariant.warning,
    );

@Preview(name: 'error — with action', size: Size(390, 56), wrapper: previewWrapper)
Widget previewStatusBarError() => StatusBar(
      message: 'Upload failed.',
      variant: StatusBannerVariant.error,
      actionLabel: 'Retry',
      onAction: () {},
    );

@Preview(name: 'success', size: Size(390, 56), wrapper: previewWrapper)
Widget previewStatusBarSuccess() => const StatusBar(
      message: 'Report saved successfully.',
      variant: StatusBannerVariant.success,
    );
