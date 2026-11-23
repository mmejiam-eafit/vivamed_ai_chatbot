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
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/open_case.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

List<StudyMetadataField> _cardFields(CaseSummary c) => [
      StudyMetadataField(label: 'Modality', value: c.modality),
      StudyMetadataField(
        label: 'Date',
        value: '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-'
            '${c.date.day.toString().padLeft(2, '0')}',
        valueKind: MetadataValueKind.numeric,
      ),
      // Every study has one, in plain words like the table's (DL D-024).
      StudyMetadataField(label: 'Status', value: c.statusSummary),
    ];

/// The Studies worklist. A stateful shell around the list itself, so the
/// list stops reading while the app is hidden (minimized or in the
/// background, not merely unfocused): its `TickerMode` goes off, which
/// pauses every provider the list watches, as a route covering the page
/// already does. The backend accepts the worklist's polling only while the
/// page is visible.
class CaseListPage extends StatefulWidget {
  const CaseListPage({super.key});

  @override
  State<CaseListPage> createState() => _CaseListPageState();
}

class _CaseListPageState extends State<CaseListPage> {
  late final AppLifecycleListener _lifecycle;
  bool _visible = _isVisible(WidgetsBinding.instance.lifecycleState);

  /// Shown, focused or not; before the first report, assume so.
  static bool _isVisible(AppLifecycleState? state) => switch (state) {
        AppLifecycleState.hidden ||
        AppLifecycleState.paused ||
        AppLifecycleState.detached =>
          false,
        _ => true,
      };

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final visible = _isVisible(state);
        if (visible != _visible) setState(() => _visible = visible);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  // Combined with the ancestors' TickerMode, so a covered route stays off.
  @override
  Widget build(BuildContext context) =>
      TickerMode(enabled: _visible, child: const _CaseList());
}

class _CaseList extends ConsumerWidget {
  const _CaseList();

  static final _appBar = AppBar(title: const Text('Cases'));

  static const _destination = 2;

  Widget _navBar(BuildContext context, int pendingReviewCount) =>
      AppNavBar(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: pendingReviewCount,
      );

  Widget _primaryNavDrawer(BuildContext context, int pendingReviewCount) =>
      PrimaryNavDrawer(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: pendingReviewCount,
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
    final pendingReviewCount = ref.watch(pendingReviewCountProvider);
    return ref.watch(worklistProvider).when(
          data: (cases) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: [
              for (final c in cases)
                StudyInfoCard(
                  title: c.title,
                  fields: _cardFields(c),
                  thumbnailUrl: mockThumbnailUrlFor(c.id),
                  onTap: () => openCase(context, c),
                ),
            ],
            worklistTable: CaseWorklistTable(
              cases: cases,
              onCaseTap: (c) => openCase(context, c),
            ),
            emptyState: const AppText('No cases available.'),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
            menuRail: _menuRail(context),
          ),
          loading: () => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: const AppLoadingIndicator(),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
            menuRail: _menuRail(context),
          ),
          error: (error, stackTrace) => CaseListTemplate(
            appBar: _appBar,
            caseSlots: const [],
            worklistTable: const SizedBox.shrink(),
            emptyState: AppText('Could not load cases: $error'),
            navBar: _navBar(context, pendingReviewCount),
            primaryNavDrawer: _primaryNavDrawer(context, pendingReviewCount),
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
