import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/processing_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';
import 'package:radiologist_helper/ui/molecules/stage_progress_row.dart';

/// A study's processing run: its status, with the open failures counted next
/// to it, and how far each stage has got. A run can be ready with failures
/// still open, since one failed image does not stop the others being used.
class RunProgressCard extends StatelessWidget {
  const RunProgressCard({
    super.key,
    required this.run,
    this.onOpenStudy,
    this.refreshError,
  });

  /// The run as last read.
  final ProcessingRun run;

  /// Why the last read failed, already worded, while [run] is the one
  /// before it; the progress shown is then older than it looks.
  final String? refreshError;

  /// Shown as "Open study" when set.
  final VoidCallback? onOpenStudy;

  static String _openFailures(int count) =>
      count == 1 ? '1 open failure' : '$count open failures';

  static List<String> _details(StageProgress p) => [
        if (p.failed > 0) '${p.failed} failed',
        for (final MapEntry(key: code, value: count) in p.skipped.entries)
          code == null ? '$count skipped' : '$count skipped (${code.label})',
        if (p.heldBack > 0) '${p.heldBack} held back for review',
        if (p.discarded > 0) '${p.discarded} discarded',
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SectionCard(
      title: 'Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ProcessingStatusChip(status: run.status),
              if (run.openFailures > 0)
                AppText(
                  _openFailures(run.openFailures),
                  style: AppTypography.bodyMd,
                  color: colors.textPrimary,
                ),
            ],
          ),
          for (final progress in run.progress) ...[
            const SizedBox(height: AppSpacing.md),
            StageProgressRow(
              label: progress.stage.label,
              done: progress.done,
              total: progress.total,
              details: _details(progress),
            ),
          ],
          if (refreshError case final refreshError?) ...[
            const SizedBox(height: AppSpacing.md),
            AppText(
              refreshError,
              style: AppTypography.bodySm,
              color: colors.textSecondary,
            ),
          ],
          if (onOpenStudy != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton(
                label: 'Open study',
                variant: AppButtonVariant.secondary,
                onPressed: onOpenStudy,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewRun = ProcessingRun(
  status: RunStatus.ready,
  openFailures: 2,
  steps: [
    ProcessingStep(
        stage: ProcessingStage.intake, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.intake, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.intake, state: ProcessingStepState.failed),
    ProcessingStep(
        stage: ProcessingStage.viewCheck, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.viewCheck, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.prediction, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.prediction, state: ProcessingStepState.failed),
    ProcessingStep(
        stage: ProcessingStage.embedding, state: ProcessingStepState.done),
    ProcessingStep(
        stage: ProcessingStage.embedding, state: ProcessingStepState.done),
  ],
);

@Preview(name: 'ready', size: Size(390, 360), wrapper: previewWrapper)
Widget previewRunProgressCard() =>
    RunProgressCard(run: _previewRun, onOpenStudy: () {});
