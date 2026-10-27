import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/similar_cases_count_header.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';
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

  // Not a primary destination itself (a drill-down page, like Study Review),
  // so every destination navigates away -- none is a no-op.
  Widget _primaryNavDrawer(BuildContext context) => PrimaryNavDrawer(
        selectedIndex: null,
        onDestinationSelected: (i) => openPrimaryDestination(context, i),
      );

  /// Builder-wrapped so Scaffold.of(context) resolves to the Scaffold this
  /// ends up inside once CaseListTemplate places it, not this page's own
  /// context, which sits above it.
  Widget _menuRail(BuildContext context) => Builder(
        builder: (context) => MenuRail(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBar = AppBar(title: const Text('Similar Cases'));
    return ref.watch(similarCasesProvider(caseId)).when(
          data: (similar) => CaseListTemplate(
            appBar: appBar,
            header: SimilarCasesCountHeader(
              count: similar.cases.length,
              imagesUsed: similar.imagesUsed,
              imagesTotal: similar.imagesTotal,
              imagesHeldBack: similar.imagesHeldBack,
            ),
            caseSlots: [
              for (final c in similar.cases)
                StudyInfoCard(
                  title: c.title,
                  fields: _cardFields(c),
                  thumbnailUrl: mockThumbnailUrlFor(c.id),
                  onTap: () => _openCase(context, c),
                ),
            ],
            worklistTable: CaseWorklistTable(
              cases: similar.cases,
              onCaseTap: (c) => _openCase(context, c),
            ),
            // No image left to search with is a different empty from a
            // search that found nothing, and the radiologist should know which.
            emptyState: AppText(
              similar.imagesUsed == 0 && similar.imagesHeldBack > 0
                  ? "No similar cases yet: this study's images are held back "
                      'for review.'
                  : 'No similar cases found.',
            ),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
          loading: () => CaseListTemplate(
            appBar: appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: const AppLoadingIndicator(),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
          error: (error, stackTrace) => CaseListTemplate(
            appBar: appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: AppText('Could not load similar cases: $error'),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
        );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(
    name: 'similar cases', size: Size(900, 700), wrapper: previewWrapperFull)
Widget previewSimilarCasesPage() => const SimilarCasesPage(caseId: 'case-1');
