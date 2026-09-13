import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

List<StudyMetadataField> _cardFields(CaseSummary c) => [
      StudyMetadataField(label: 'Modality', value: c.modality),
      StudyMetadataField(
        label: 'Date',
        value: '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-'
            '${c.date.day.toString().padLeft(2, '0')}',
        valueKind: MetadataValueKind.numeric,
      ),
    ];

/// Reached from Study Review's "View Similar Studies" action -- composes
/// `CaseListTemplate` exactly like its own `'wide — similar cases'` preview.
class SimilarCasesPage extends ConsumerWidget {
  const SimilarCasesPage({super.key, required this.caseId});

  final String caseId;

  void _openCase(BuildContext context, CaseSummary c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudyReviewPage(caseId: c.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBar = AppBar(title: const Text('Similar Cases'));
    return ref.watch(similarCasesProvider(caseId)).when(
          data: (cases) => CaseListTemplate(
            appBar: appBar,
            header: AppText(
              '${cases.length} similar '
              '${cases.length == 1 ? 'case' : 'cases'} found',
              style: AppTypography.headingSm,
              color: context.colors.textPrimary,
            ),
            caseSlots: [
              for (final c in cases)
                StudyInfoCard(
                  title: c.title,
                  fields: _cardFields(c),
                  thumbnailUrl: mockThumbnailUrlFor(c.id),
                  onTap: () => _openCase(context, c),
                ),
            ],
            worklistTable: CaseWorklistTable(
              cases: cases,
              onCaseTap: (c) => _openCase(context, c),
            ),
            emptyState: const AppText('No similar cases found.'),
          ),
          loading: () => Scaffold(
            appBar: appBar,
            body: const Center(child: AppLoadingIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: appBar,
            body: Center(child: Text('Could not load similar cases: $error')),
          ),
        );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'similar cases', size: Size(900, 700), wrapper: previewWrapperFull)
Widget previewSimilarCasesPage() => const SimilarCasesPage(caseId: 'case-1');
