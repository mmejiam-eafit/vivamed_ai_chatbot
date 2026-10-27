import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Where an image's review stands. App status, not clinical severity, so it
/// reads the status pairs and never sits inside a component that shows
/// severity (DL D-021). Each state carries its label and an icon of its own
/// shape, never hue alone.
class ReviewStatusChip extends StatelessWidget {
  const ReviewStatusChip({super.key, required this.status});

  final ReviewStatus status;

  static String labelFor(ReviewStatus status) => switch (status) {
        ReviewStatus.pending => 'Needs review',
        ReviewStatus.decided => 'Processing',
        ReviewStatus.applied => 'Applied',
      };

  static IconData iconFor(ReviewStatus status) => switch (status) {
        ReviewStatus.pending => Icons.flag_outlined,
        ReviewStatus.decided => Icons.autorenew,
        ReviewStatus.applied => Icons.check_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (status) {
      ReviewStatus.pending => (colors.statusWarningSubdued, colors.statusWarning),
      ReviewStatus.decided => (colors.statusInfoSubdued, colors.statusInfo),
      ReviewStatus.applied => (colors.statusSuccessSubdued, colors.statusSuccess),
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
          // Flexible so a narrow table column wraps the label instead of
          // overflowing, as SeverityChip does.
          Flexible(
            child: AppText(
              labelFor(status),
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
