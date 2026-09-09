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
    this.isAlarm = true,
  });

  final String name;
  final SeverityLevel severity;
  final VoidCallback? onTap;
  final bool isExpanded;

  /// Whether this row may carry the viewport's one Layer-5 alarm (DL §5.2).
  /// The list owner decides: when several findings share the top severity it
  /// aggregates them into a single chip of its own and passes `false` here,
  /// because three critical chips are three alarms and three alarms are
  /// indistinguishable from none.
  ///
  /// Ignored by `normal` and `mild`, which are never alarm levels — see
  /// [_showsAlarm].
  final bool isAlarm;

  /// `normal` and `mild` are demoted unconditionally, whatever the caller
  /// asks for: alarm treatment on a non-urgent finding spends the attention
  /// budget that makes a critical one findable (DL §5.4).
  bool get _showsAlarm =>
      isAlarm &&
      (severity == SeverityLevel.moderate || severity == SeverityLevel.critical);

  static String _labelFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => 'NORMAL',
        SeverityLevel.mild => 'MILD',
        SeverityLevel.moderate => 'MODERATE',
        SeverityLevel.critical => 'CRITICAL',
      };

  static Color _bgFor(SeverityData severity, SeverityLevel level) =>
      switch (level) {
        SeverityLevel.normal => severity.normalBg,
        SeverityLevel.mild => severity.mildBg,
        SeverityLevel.moderate => severity.moderateBg,
        SeverityLevel.critical => severity.criticalBg,
      };

  static Color _colorFor(SeverityData severity, SeverityLevel level) =>
      switch (level) {
        SeverityLevel.normal => severity.normal,
        SeverityLevel.mild => severity.mild,
        SeverityLevel.moderate => severity.moderate,
        SeverityLevel.critical => severity.critical,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final severityColors = context.severity;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderCard,
      child: Padding(
        // Dense, not generous — this is a scanning surface (DL §7.1).
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                name,
                style: AppTypography.bodyMd,
                // Collapsed: clamp to fit the list. Expanded: the full name
                // must be reachable (DL §4.6) — this is the row's only
                // carrier of it, so it wraps instead of staying cut off.
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                maxLines: isExpanded ? null : 1,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _SeverityMark(
              severity: severity,
              showsAlarm: _showsAlarm,
              severityColors: severityColors,
              quietLabelColor: colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            AppIcon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: colors.icon,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

/// The row's severity indicator, in one of two ranks.
///
/// **Alarm (Layer 5)** — full-chroma pair behind a small, high-weight label.
/// **Quiet (Layer 3)** — the same label at the same size but body voice and
/// neutral, on no fill. Weight is rank, size is scope (DL §4.4), so the
/// demotion drops weight and chroma without dropping below the 12px clinical
/// floor (DL §4.5).
///
/// Both ranks keep the text label and the distinct dot silhouette, because
/// severity may never rest on hue alone (DL §3.6) — demoting a finding must
/// not make its level unreadable, only unshouted.
class _SeverityMark extends StatelessWidget {
  const _SeverityMark({
    required this.severity,
    required this.showsAlarm,
    required this.severityColors,
    required this.quietLabelColor,
  });

  final SeverityLevel severity;
  final bool showsAlarm;
  final SeverityData severityColors;
  final Color quietLabelColor;

  @override
  Widget build(BuildContext context) {
    final mark = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeverityDot(severity: severity),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          FindingRow._labelFor(severity),
          style: showsAlarm ? AppTypography.labelMd : AppTypography.bodySm,
          color: showsAlarm
              ? FindingRow._colorFor(severityColors, severity)
              : quietLabelColor,
        ),
      ],
    );

    if (!showsAlarm) return mark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: FindingRow._bgFor(severityColors, severity),
        borderRadius: AppRadius.borderInput,
      ),
      child: mark,
    );
  }
}
