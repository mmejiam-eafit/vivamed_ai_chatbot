import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip({
    super.key,
    required this.severity,
  });

  final SeverityLevel severity;

  static String labelFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => 'NORMAL',
        SeverityLevel.mild => 'MILD',
        SeverityLevel.moderate => 'MODERATE',
        SeverityLevel.critical => 'CRITICAL',
      };

  static Color bgFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => SeverityTokens.normalBg,
        SeverityLevel.mild => SeverityTokens.mildBg,
        SeverityLevel.moderate => SeverityTokens.moderateBg,
        SeverityLevel.critical => SeverityTokens.criticalBg,
      };

  static Color colorFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => SeverityTokens.normal,
        SeverityLevel.mild => SeverityTokens.mild,
        SeverityLevel.moderate => SeverityTokens.moderate,
        SeverityLevel.critical => SeverityTokens.critical,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgFor(severity),
        borderRadius: AppRadius.borderInput,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeverityDot(severity: severity),
          const SizedBox(width: AppSpacing.xs),
          AppText(
            labelFor(severity),
            style: AppTypography.labelSm,
            color: colorFor(severity),
          ),
        ],
      ),
    );
  }
}
