import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';

class CaseListTemplate extends StatelessWidget {
  const CaseListTemplate({
    super.key,
    required this.appBar,
    required this.caseSlots,
    required this.worklistTable,
    this.header,
    this.statusBar,
    this.emptyState,
    this.navBar,
  });

  final PreferredSizeWidget appBar;

  /// Compact and medium tiers — one `StudyInfoCard` per case.
  final List<Widget> caseSlots;

  /// Expanded and ultrawide tiers — the dense sortable table (DT §9.5).
  /// An opaque slot like every other template slot: this template never sees
  /// the underlying case data, only whatever widget the page builds from it.
  final Widget worklistTable;

  final Widget? header;
  final Widget? statusBar;
  final Widget? emptyState;
  final Widget? navBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      bottomNavigationBar: navBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxWidth.layoutTier;
          return Column(
            children: [
              if (statusBar != null) statusBar!,
              if (header != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: header,
                ),
              Expanded(child: _buildContent(tier)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AppLayoutTier tier) {
    if (caseSlots.isEmpty && emptyState != null) {
      return Center(child: emptyState);
    }

    switch (tier) {
      case AppLayoutTier.compact:
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: caseSlots.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (_, i) => caseSlots[i],
        );

      case AppLayoutTier.medium:
        // Two columns via Wrap, not GridView's fixed-aspect-ratio delegate
        // (the only kind Flutter's grid delegates offer) -- a StudyInfoCard
        // with more metadata fields, or 200%-scaled text, needs its row to
        // grow with it rather than clip inside a fixed-height cell (gap 20).
        return Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columnWidth =
                      (constraints.maxWidth - AppSpacing.lg) / 2;
                  return Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      for (final slot in caseSlots)
                        SizedBox(width: columnWidth, child: slot),
                    ],
                  );
                },
              ),
            ),
          ),
        );

      case AppLayoutTier.expanded:
      case AppLayoutTier.ultrawide:
        // Ultrawide caps at worklistMaxWidth (DT §9.5); expanded has no
        // narrower ceiling of its own to apply, so the constraint is a no-op
        // there (its own tier max, 1599, is already below the cap).
        return Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.worklistMaxWidth),
            child: worklistTable,
          ),
        );
    }
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewCaseFields = [
  StudyMetadataField(label: 'Patient', value: 'Anonymous'),
  StudyMetadataField(
    label: 'Date',
    value: '2026-04-12',
    valueKind: MetadataValueKind.numeric,
  ),
  StudyMetadataField(label: 'Modality', value: 'CXR'),
  StudyMetadataField(
    label: 'Similarity',
    value: '94 %',
    valueKind: MetadataValueKind.numeric,
  ),
];

const _previewHistoryFields = [
  StudyMetadataField(
    label: 'Date',
    value: '2025-11-03',
    valueKind: MetadataValueKind.numeric,
  ),
  StudyMetadataField(label: 'Modality', value: 'CXR'),
  StudyMetadataField(label: 'Findings', value: 'Mild cardiomegaly'),
];

List<Widget> _previewCaseCards(int count, List<StudyMetadataField> fields) =>
    List.generate(
      count,
      (i) => StudyInfoCard(
        title: 'Chest X-Ray — PA view ${i + 1}',
        fields: fields,
        thumbnailUrl: 'https://picsum.photos/seed/case$i/80/80',
        thumbnailBadge: '${i + 1}',
      ),
    );

List<CaseSummary> _previewCases() => [
      CaseSummary(
        id: 'preview-1',
        title: 'Chest X-Ray — PA view 1',
        patient: 'Anonymous 1',
        modality: 'CXR',
        date: DateTime(2026, 4, 12),
        confidence: 0.94,
        severity: SeverityLevel.critical,
      ),
      CaseSummary(
        id: 'preview-2',
        title: 'Chest X-Ray — PA view 2',
        patient: 'Anonymous 2',
        modality: 'CXR',
        date: DateTime(2026, 3, 28),
        confidence: 0.81,
        severity: SeverityLevel.moderate,
      ),
      CaseSummary(
        id: 'preview-3',
        title: 'Chest X-Ray — PA view 3',
        patient: 'Anonymous 3',
        modality: 'CXR',
        date: DateTime(2025, 11, 3),
        confidence: 0.67,
        severity: SeverityLevel.normal,
      ),
    ];

AppNavBar _previewNavBar() =>
    AppNavBar(selectedIndex: 2, onDestinationSelected: (_) {});

@Preview(
    name: 'wide — similar cases',
    size: Size(900, 700),
    wrapper: previewWrapperFull)
Widget previewCaseListWide() => CaseListTemplate(
      appBar: AppBar(title: const Text('Similar Cases')),
      header: const AppText(
        '3 similar cases found',
        style: AppTypography.headingSm,
        color: AppColors.textPrimary,
      ),
      caseSlots: _previewCaseCards(3, _previewCaseFields),
      worklistTable: CaseWorklistTable(cases: _previewCases()),
    );

@Preview(
    name: 'narrow — patient history',
    size: Size(390, 700),
    wrapper: previewWrapperFull)
Widget previewCaseListNarrow() => CaseListTemplate(
      appBar: AppBar(title: const Text('Patient History')),
      caseSlots: _previewCaseCards(4, _previewHistoryFields),
      worklistTable: CaseWorklistTable(cases: _previewCases()),
    );

@Preview(
    name: 'expanded — worklist table',
    size: Size(1200, 700),
    wrapper: previewWrapperFull)
Widget previewCaseListExpanded() => CaseListTemplate(
      appBar: AppBar(title: const Text('Similar Cases')),
      caseSlots: _previewCaseCards(3, _previewCaseFields),
      worklistTable: CaseWorklistTable(cases: _previewCases()),
    );

@Preview(name: 'studies — with nav bar', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewCaseListWithNavBar() => CaseListTemplate(
      appBar: AppBar(title: const Text('Studies')),
      caseSlots: _previewCaseCards(3, _previewCaseFields),
      worklistTable: CaseWorklistTable(cases: _previewCases()),
      navBar: _previewNavBar(),
    );

@Preview(name: 'empty state', size: Size(390, 400), wrapper: previewWrapperFull)
Widget previewCaseListEmpty() => CaseListTemplate(
      appBar: AppBar(title: const Text('Similar Cases')),
      caseSlots: const [],
      worklistTable: const CaseWorklistTable(cases: []),
      emptyState: const AppText(
        'No similar cases found.',
        style: AppTypography.bodyMd,
        color: AppColors.textMuted,
      ),
    );
