import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';

class CaseListTemplate extends StatelessWidget {
  const CaseListTemplate({
    super.key,
    required this.appBar,
    required this.caseSlots,
    this.header,
    this.statusBar,
    this.emptyState,
  });

  final PreferredSizeWidget appBar;
  final List<Widget> caseSlots;
  final Widget? header;
  final Widget? statusBar;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppLayout.templateSplitWidth;
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
              Expanded(child: _buildContent(isWide)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isWide) {
    if (caseSlots.isEmpty && emptyState != null) {
      return Center(child: emptyState);
    }

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.4,
            ),
            itemCount: caseSlots.length,
            itemBuilder: (_, i) => caseSlots[i],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: caseSlots.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, i) => caseSlots[i],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewCaseFields = [
  StudyMetadataField(label: 'Patient', value: 'Anonymous'),
  StudyMetadataField(label: 'Date', value: '2026-04-12'),
  StudyMetadataField(label: 'Modality', value: 'CXR'),
  StudyMetadataField(label: 'Similarity', value: '94 %'),
];

const _previewHistoryFields = [
  StudyMetadataField(label: 'Date', value: '2025-11-03'),
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
    );

@Preview(
    name: 'narrow — patient history',
    size: Size(390, 700),
    wrapper: previewWrapperFull)
Widget previewCaseListNarrow() => CaseListTemplate(
      appBar: AppBar(title: const Text('Patient History')),
      caseSlots: _previewCaseCards(4, _previewHistoryFields),
    );

@Preview(name: 'empty state', size: Size(390, 400), wrapper: previewWrapperFull)
Widget previewCaseListEmpty() => CaseListTemplate(
      appBar: AppBar(title: const Text('Similar Cases')),
      caseSlots: const [],
      emptyState: const AppText(
        'No similar cases found.',
        style: AppTypography.bodyMd,
        color: AppColors.textMuted,
      ),
    );
