import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip({
    super.key,
    required this.severity,
    this.label,
  });

  final SeverityLevel severity;

  /// Overrides the level's own label. Used for the aggregated alarm a
  /// findings list collapses to — "3 CRITICAL FINDINGS" is one Layer-5
  /// element where three separate chips would be three (DL §5.2).
  final String? label;

  static String labelFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => 'NORMAL',
        SeverityLevel.mild => 'MILD',
        SeverityLevel.moderate => 'MODERATE',
        SeverityLevel.critical => 'CRITICAL',
      };

  static Color bgFor(SeverityData severity, SeverityLevel level) =>
      switch (level) {
        SeverityLevel.normal => severity.normalBg,
        SeverityLevel.mild => severity.mildBg,
        SeverityLevel.moderate => severity.moderateBg,
        SeverityLevel.critical => severity.criticalBg,
      };

  static Color colorFor(SeverityData severity, SeverityLevel level) =>
      switch (level) {
        SeverityLevel.normal => severity.normal,
        SeverityLevel.mild => severity.mild,
        SeverityLevel.moderate => severity.moderate,
        SeverityLevel.critical => severity.critical,
      };

  @override
  Widget build(BuildContext context) {
    final severityColors = context.severity;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgFor(severityColors, severity),
        borderRadius: AppRadius.borderInput,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeverityDot(severity: severity),
          const SizedBox(width: AppSpacing.xs),
          // Flexible, not a bare AppText: a fixed-width host (a dense table
          // column, e.g.) has nowhere to put an overflow otherwise — this
          // lets the label wrap instead of forcing the Row past its bounds.
          Flexible(
            child: AppText(
              label ?? labelFor(severity),
              // labelMd, not labelSm — labelSm's 10px sits below the 12px
              // clinical floor (DL §4.5) and this label carries the colour-
              // vision-deficiency redundancy channel (DL §3.6).
              style: AppTypography.labelMd,
              color: colorFor(severityColors, severity),
            ),
          ),
        ],
      ),
    );
  }
}
