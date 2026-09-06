import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// Inlines the severity chip display to avoid importing a sibling molecule.
class FindingRow extends StatelessWidget {
  const FindingRow({
    super.key,
    required this.name,
    required this.severity,
    this.onTap,
    this.isExpanded = false,
  });

  final String name;
  final SeverityLevel severity;
  final VoidCallback? onTap;
  final bool isExpanded;

  static String _labelFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => 'NORMAL',
        SeverityLevel.mild => 'MILD',
        SeverityLevel.moderate => 'MODERATE',
        SeverityLevel.critical => 'CRITICAL',
      };

  static Color _bgFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => SeverityTokens.normalBg,
        SeverityLevel.mild => SeverityTokens.mildBg,
        SeverityLevel.moderate => SeverityTokens.moderateBg,
        SeverityLevel.critical => SeverityTokens.criticalBg,
      };

  static Color _colorFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => SeverityTokens.normal,
        SeverityLevel.mild => SeverityTokens.mild,
        SeverityLevel.moderate => SeverityTokens.moderate,
        SeverityLevel.critical => SeverityTokens.critical,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                name,
                style: AppTypography.bodyMd,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: _bgFor(severity),
                borderRadius: AppRadius.borderInput,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeverityDot(severity: severity),
                  const SizedBox(width: AppSpacing.xs),
                  AppText(
                    _labelFor(severity),
                    style: AppTypography.labelSm,
                    color: _colorFor(severity),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppIcon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.icon,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
