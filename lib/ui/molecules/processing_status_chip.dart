import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// Where a study's processing run stands. App status, not clinical severity,
/// so it reads the status pairs and never sits inside a component that shows
/// severity (DL D-023). Each status carries its label and an icon of its own
/// shape, never hue alone: queued and processing share the info pair.
class ProcessingStatusChip extends StatelessWidget {
  const ProcessingStatusChip({super.key, required this.status});

  final RunStatus status;

  static IconData iconFor(RunStatus status) => switch (status) {
        RunStatus.queued => Icons.schedule,
        RunStatus.processing => Icons.autorenew,
        RunStatus.ready => Icons.check_circle_outline,
        RunStatus.failed => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (status) {
      RunStatus.queued || RunStatus.processing => (
          colors.statusInfoSubdued,
          colors.statusInfo
        ),
      RunStatus.ready => (colors.statusSuccessSubdued, colors.statusSuccess),
      RunStatus.failed => (colors.statusErrorSubdued, colors.statusError),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderInput,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(iconFor(status), size: AppIconSize.sm, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: AppText(
              status.label,
              // labelMd: labelSm's 10px is below the 12px floor (DL §4.5).
              style: AppTypography.labelMd,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'queued', size: Size(160, 48), wrapper: previewWrapper)
Widget previewProcessingStatusChipQueued() =>
    const ProcessingStatusChip(status: RunStatus.queued);

@Preview(name: 'processing', size: Size(160, 48), wrapper: previewWrapper)
Widget previewProcessingStatusChipProcessing() =>
    const ProcessingStatusChip(status: RunStatus.processing);

@Preview(name: 'ready', size: Size(160, 48), wrapper: previewWrapper)
Widget previewProcessingStatusChipReady() =>
    const ProcessingStatusChip(status: RunStatus.ready);

@Preview(name: 'failed', size: Size(160, 48), wrapper: previewWrapper)
Widget previewProcessingStatusChipFailed() =>
    const ProcessingStatusChip(status: RunStatus.failed);
