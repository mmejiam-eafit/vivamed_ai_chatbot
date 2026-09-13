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
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
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

class CaseListPage extends ConsumerWidget {
  const CaseListPage({super.key});

  static final _appBar = AppBar(title: const Text('Cases'));

  Widget _navBar(BuildContext context) => AppNavBar(
        selectedIndex: 2,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst);
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
          }
        },
      );

  void _openCase(BuildContext context, CaseSummary c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudyReviewPage(caseId: c.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(casesProvider).when(
          data: (cases) => CaseListTemplate(
            appBar: _appBar,
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
            emptyState: const AppText('No cases available.'),
            navBar: _navBar(context),
          ),
          loading: () => Scaffold(
            appBar: _appBar,
            body: const Center(child: AppLoadingIndicator()),
            bottomNavigationBar: _navBar(context),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: _appBar,
            body: Center(child: Text('Could not load cases: $error')),
            bottomNavigationBar: _navBar(context),
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
