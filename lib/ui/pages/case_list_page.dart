import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

const _placeholderFields = [
  StudyMetadataField(label: 'Modality', value: 'CXR'),
  StudyMetadataField(label: 'Date', value: '—'),
];

class CaseListPage extends StatelessWidget {
  const CaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CaseListTemplate(
      appBar: AppBar(title: const Text('Cases')),
      caseSlots: const [
        StudyInfoCard(title: 'Chest X-Ray', fields: _placeholderFields),
        StudyInfoCard(title: 'Abdominal CT', fields: _placeholderFields),
      ],
      emptyState: const AppText('No cases available.'),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(900, 700), wrapper: previewWrapperFull)
Widget previewCaseListPageWide() => const CaseListPage();

@Preview(name: 'narrow', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewCaseListPageNarrow() => const CaseListPage();
