import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

List<StudyMetadataField> _cardFields(
  CaseSummary c,
  List<ImageReview>? heldBack,
) =>
    [
      StudyMetadataField(label: 'Modality', value: c.modality),
      StudyMetadataField(
        label: 'Date',
        value: '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-'
            '${c.date.day.toString().padLeft(2, '0')}',
        valueKind: MetadataValueKind.numeric,
      ),
      // Only a study with an image held back gets the row (DL D-022).
      if (heldBack != null)
        StudyMetadataField(label: 'Review', value: heldBackSummary(heldBack)),
    ];

class CaseListPage extends ConsumerWidget {
  const CaseListPage({super.key});

  static final _appBar = AppBar(title: const Text('Cases'));

  static const _destination = 2;

  Widget _navBar(BuildContext context) => AppNavBar(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
      );

  Widget _primaryNavDrawer(BuildContext context) => PrimaryNavDrawer(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
      );

  /// Builder-wrapped so Scaffold.of(context) resolves to the Scaffold this
  /// ends up inside once CaseListTemplate places it, not this page's own
  /// context, which sits above it.
  Widget _menuRail(BuildContext context) => Builder(
        builder: (context) => MenuRail(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
      );

  void _openCase(BuildContext context, CaseSummary c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudyReviewPage(caseId: c.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBack = ref.watch(heldBackReviewsByCaseProvider);
    return ref.watch(casesProvider).when(
          data: (cases) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: [
              for (final c in cases)
                StudyInfoCard(
                  title: c.title,
                  fields: _cardFields(c, heldBack[c.id]),
                  thumbnailUrl: mockThumbnailUrlFor(c.id),
                  onTap: () => _openCase(context, c),
                ),
            ],
            worklistTable: CaseWorklistTable(
              cases: cases,
              heldBack: heldBack,
              onCaseTap: (c) => _openCase(context, c),
            ),
            emptyState: const AppText('No cases available.'),
            navBar: _navBar(context),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
          loading: () => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: const AppLoadingIndicator(),
            navBar: _navBar(context),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
          error: (error, stackTrace) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: AppText('Could not load cases: $error'),
            navBar: _navBar(context),
            primaryNavDrawer: _primaryNavDrawer(context),
            menuRail: _menuRail(context),
          ),
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
