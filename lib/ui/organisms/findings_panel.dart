import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/finding_row.dart';

class FindingItem {
  const FindingItem({required this.name, required this.severity});

  final String name;
  final SeverityLevel severity;
}

class FindingsPanel extends StatefulWidget {
  const FindingsPanel({
    super.key,
    required this.findings,
    this.title = 'Findings',
  });

  final List<FindingItem> findings;
  final String title;

  @override
  State<FindingsPanel> createState() => _FindingsPanelState();
}

class _FindingsPanelState extends State<FindingsPanel> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderPanel,
        border: Border.all(color: AppColors.border),
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
              child: AppText(
                widget.title,
                style: AppTypography.headingSm,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubdued),
            if (widget.findings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: AppText(
                    'No findings recorded.',
                    style: AppTypography.bodySm,
                    color: AppColors.textMuted,
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
