import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/finding_row.dart';
import 'package:radiologist_helper/ui/molecules/severity_chip.dart';

class FindingsPanel extends StatefulWidget {
  const FindingsPanel({
    super.key,
    required this.findings,
    this.title = 'Findings',
  });

  final List<FindingItem> findings;
  final String title;

  /// Severity levels that may sound an alarm at all, most urgent first.
  /// `normal` and `mild` are absent by design — see `FindingRow.isAlarm`.
  static const List<SeverityLevel> alarmLevels = [
    SeverityLevel.critical,
    SeverityLevel.moderate,
  ];

  static String labelFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => 'NORMAL',
        SeverityLevel.mild => 'MILD',
        SeverityLevel.moderate => 'MODERATE',
        SeverityLevel.critical => 'CRITICAL',
      };

  @override
  State<FindingsPanel> createState() => _FindingsPanelState();
}

/// The panel's one Layer-5 decision, resolved from the findings list.
///
/// DL §5.2 caps a viewport at a single alarm: several findings sharing the top
/// severity aggregate into one chip, because three critical chips are three
/// alarms and three alarms are indistinguishable from none. A lone alarm-level
/// finding needs no aggregate — it already is the one alarm, and keeps the row
/// treatment DL §5.4 prescribes.
class _AlarmSummary {
  const _AlarmSummary({required this.level, required this.count, this.rowIndex});

  final SeverityLevel level;
  final int count;

  /// Set only when [count] is 1 — the row that keeps its own chip.
  final int? rowIndex;

  bool get isAggregated => count > 1;

  String get label =>
      '$count ${FindingsPanel.labelFor(level)} '
      '${count == 1 ? 'FINDING' : 'FINDINGS'}';

  /// `null` when nothing in the list is an alarm level at all.
  static _AlarmSummary? from(List<FindingItem> findings) {
    for (final level in FindingsPanel.alarmLevels) {
      final matches = <int>[];
      for (var i = 0; i < findings.length; i++) {
        if (findings[i].severity == level) matches.add(i);
      }
      if (matches.isEmpty) continue;
      return _AlarmSummary(
        level: level,
        count: matches.length,
        rowIndex: matches.length == 1 ? matches.single : null,
      );
    }
    return null;
  }
}

class _FindingsPanelState extends State<FindingsPanel> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final summary = _AlarmSummary.from(widget.findings);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderPanel,
        border: Border.all(color: colors.border),
        boxShadow: AppElevation.card,
      ),
      // SingleChildScrollView prevents RenderFlex overflow when the panel is
      // placed in a parent that constrains height below the content's natural size.
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      widget.title,
                      style: AppTypography.headingSm,
                      color: colors.textPrimary,
                    ),
                  ),
                  // The aggregate alarm, and the only Layer-5 element on the
                  // screen when it renders — every row goes quiet behind it.
                  if (summary != null && summary.isAggregated) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SeverityChip(
                      severity: summary.level,
                      label: summary.label,
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: colors.borderSubdued),
            if (widget.findings.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: AppText(
                    'No findings recorded.',
                    style: AppTypography.bodySm,
                    color: colors.textMuted,
                  ),
                ),
              )
            else
              ...List.generate(widget.findings.length, (i) {
                final item = widget.findings[i];
                return FindingRow(
                  name: item.name,
                  severity: item.severity,
                  isExpanded: _expanded.contains(i),
                  // Exactly one alarm per viewport (DL §5.2): either the
                  // header carries it, or a lone alarm-level row does.
                  isAlarm: summary != null && summary.rowIndex == i,
                  onTap: () => setState(() {
                    if (_expanded.contains(i)) {
                      _expanded.remove(i);
                    } else {
                      _expanded.add(i);
                    }
                  }),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewFindings = [
  FindingItem(name: 'Right lower lobe consolidation', severity: SeverityLevel.moderate),
  FindingItem(name: 'Tension pneumothorax', severity: SeverityLevel.critical),
  FindingItem(
    name: 'Cardiac silhouette — within normal limits',
    severity: SeverityLevel.normal,
  ),
];

@Preview(name: 'with findings', size: Size(360, 260), wrapper: previewWrapper)
Widget previewFindingsPanelFull() => const FindingsPanel(findings: _previewFindings);

@Preview(name: 'empty', size: Size(360, 120), wrapper: previewWrapper)
Widget previewFindingsPanelEmpty() => const FindingsPanel(findings: []);

@Preview(name: 'single critical', size: Size(360, 120), wrapper: previewWrapper)
Widget previewFindingsPanelSingle() => const FindingsPanel(
      findings: [FindingItem(name: 'Tension pneumothorax', severity: SeverityLevel.critical)],
    );

/// The aggregation path: several findings at the top severity collapse to one
/// alarm in the header, and every row goes quiet behind it (DL §5.2). Compare
/// against 'single critical' above, where the lone row keeps its own chip.
@Preview(name: 'aggregated alarm', size: Size(360, 260), wrapper: previewWrapper)
Widget previewFindingsPanelAggregated() => const FindingsPanel(
      findings: [
        FindingItem(name: 'Tension pneumothorax', severity: SeverityLevel.critical),
        FindingItem(name: 'Aortic dissection', severity: SeverityLevel.critical),
        FindingItem(name: 'Right lower lobe consolidation', severity: SeverityLevel.moderate),
        FindingItem(name: 'Mild cardiomegaly', severity: SeverityLevel.mild),
      ],
    );
