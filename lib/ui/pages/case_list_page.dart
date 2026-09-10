import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

/// One canonical placeholder list — the source both `caseSlots` (compact and
/// medium) and `worklistTable` (expanded and up) are built from, so the two
/// representations of "the same cases" can't drift out of sync.
final _cases = [
  CaseSummary(
    title: 'Chest X-Ray',
    patient: 'Anonymous 1',
    modality: 'CXR',
    date: DateTime(2026, 4, 12),
    confidence: 0.94,
    severity: SeverityLevel.moderate,
  ),
  CaseSummary(
    title: 'Abdominal CT',
    patient: 'Anonymous 2',
    modality: 'CT',
    date: DateTime(2026, 3, 5),
    confidence: 0.78,
    severity: SeverityLevel.normal,
  ),
];

List<StudyMetadataField> _cardFields(CaseSummary c) => [
      StudyMetadataField(label: 'Modality', value: c.modality),
      StudyMetadataField(
        label: 'Date',
        value: '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-'
            '${c.date.day.toString().padLeft(2, '0')}',
        valueKind: MetadataValueKind.numeric,
      ),
    ];

class CaseListPage extends StatelessWidget {
  const CaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CaseListTemplate(
      appBar: AppBar(title: const Text('Cases')),
      caseSlots: [
        for (final c in _cases)
          StudyInfoCard(title: c.title, fields: _cardFields(c)),
      ],
      worklistTable: CaseWorklistTable(cases: _cases),
      emptyState: const AppText('No cases available.'),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(900, 700), wrapper: previewWrapperFull)
Widget previewCaseListPageWide() => const CaseListPage();

@Preview(name: 'narrow', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewCaseListPageNarrow() => const CaseListPage();

@Preview(name: 'expanded', size: Size(1200, 700), wrapper: previewWrapperFull)
Widget previewCaseListPageExpanded() => const CaseListPage();
