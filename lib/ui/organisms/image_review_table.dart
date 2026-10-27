import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';

String _formatDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The two recorded labels side by side, as transcribed: header view, then
/// the dataset's class.
String _recorded(RecordedLabels recorded) =>
    '${recorded.viewPosition?.code ?? '—'} · '
    '${recorded.orientation?.label ?? '—'}';

String _decision(ReviewDecision? decision) => switch (decision?.outcome) {
      null => '',
      ReviewOutcome.setView => decision!.view!.displayName,
      ReviewOutcome.unusable => 'Unusable',
      ReviewOutcome.confirmed => 'Confirmed',
    };

/// The review queue at expanded and up (DT §9.5): the same dense `DataTable`
/// as the Case List worklist, with rows that grow with wrapped text instead
/// of clipping. Not sortable: rows keep the queue's own order, needs review
/// first, so what still needs a radiologist never sinks below what is done.
///
/// Shows review status, so it holds no severity (DL D-021).
class ImageReviewTable extends StatelessWidget {
  const ImageReviewTable({super.key, required this.items, this.onReviewTap});

  final List<ReviewQueueItem> items;
  final ValueChanged<ImageReview>? onReviewTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget cellText(String text, {TextStyle? style}) => AppText(
          text,
          style: style ?? AppTypography.bodyMd,
          color: colors.textPrimary,
        );

    return Theme(
      // DataTable's row divider takes its color from the ambient Theme, as
      // in CaseWorklistTable.
      data: Theme.of(context).copyWith(dividerColor: colors.borderSubdued),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DataTable(
          dataRowMinHeight: AppInteraction.minTouchTarget,
          dataRowMaxHeight: double.infinity,
          showCheckboxColumn: false,
          headingTextStyle:
              AppTypography.labelMd.copyWith(color: colors.textSecondary),
          headingRowColor: WidgetStateProperty.all(colors.surfaceSubdued),
          columns: const [
            DataColumn(
              label: Expanded(child: Text('Status')),
              columnWidth: FlexColumnWidth(1.3),
            ),
            DataColumn(
              label: Expanded(child: Text('Patient')),
              columnWidth: FlexColumnWidth(1.5),
            ),
            DataColumn(
              label: Expanded(child: Text('Date')),
              columnWidth: FlexColumnWidth(1.2),
            ),
            DataColumn(
              label: Expanded(child: Text('Reason')),
              columnWidth: FlexColumnWidth(2),
            ),
            DataColumn(
              label: Expanded(child: Text('Recorded')),
              columnWidth: FlexColumnWidth(1.3),
            ),
            DataColumn(
              label: Expanded(child: Text('Decision')),
              columnWidth: FlexColumnWidth(1.5),
            ),
          ],
          rows: [
            for (final item in items)
              DataRow(
                onSelectChanged: onReviewTap == null
                    ? null
                    : (_) => onReviewTap!(item.review),
                cells: [
                  DataCell(ReviewStatusChip(status: item.review.status)),
                  DataCell(cellText(item.caseSummary.patient)),
                  DataCell(cellText(_formatDate(item.caseSummary.date),
                      style: AppTypography.numeric)),
                  DataCell(cellText(item.review.reason.label)),
                  DataCell(cellText(_recorded(item.review.image.recorded),
                      style: AppTypography.mono)),
                  DataCell(cellText(_decision(item.review.decision))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

final _previewCase = CaseSummary(
  id: 'preview-case',
  title: 'Chest X-Ray',
  patient: 'Anonymous 7',
  modality: 'CXR',
  date: DateTime(2026, 10, 22),
  confidence: 0.76,
  severity: SeverityLevel.mild,
);

const _previewImage = StudyImage(
  id: 'preview-image',
  url: 'https://picsum.photos/seed/preview-review/800/800',
  recorded: RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.frontal,
  ),
);

@Preview(name: 'queue', size: Size(1120, 320), wrapper: previewWrapper)
Widget previewImageReviewTable() => ImageReviewTable(
      items: [
        (
          review: const ImageReview(
            id: 'preview-1',
            status: ReviewStatus.pending,
            reason: ReviewReason.viewLabelsDisagree,
            image: _previewImage,
            caseId: 'preview-case',
            otherImages: [],
            report: [],
          ),
          caseSummary: _previewCase,
        ),
        (
          review: ImageReview(
            id: 'preview-2',
            status: ReviewStatus.decided,
            reason: ReviewReason.viewLabelsDisagree,
            image: _previewImage,
            caseId: 'preview-case',
            otherImages: const [],
            report: const [],
            decision: ReviewDecision(
              outcome: ReviewOutcome.setView,
              view: ImageView.frontal,
              decidedBy: 'Dr. A. Ramírez',
              decidedAt: DateTime.utc(2026, 10, 27, 9),
            ),
          ),
          caseSummary: _previewCase,
        ),
      ],
      onReviewTap: (_) {},
    );
