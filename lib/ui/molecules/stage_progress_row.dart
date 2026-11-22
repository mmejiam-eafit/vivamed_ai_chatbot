import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// How far one stage of a study's processing has got: its name, how many of
/// its steps are done, and what became of the others ("1 failed · 2
/// skipped"). Neutral text: a failure's color, if any, belongs to the run's
/// status, not to every count of it (DL D-023).
class StageProgressRow extends StatelessWidget {
  const StageProgressRow({
    super.key,
    required this.label,
    required this.done,
    required this.total,
    this.details = const [],
  });

  final String label;
  final int done;
  final int total;

  /// What became of the steps that are not done, already worded; shown only
  /// when there are any.
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // stretch: the Wrap below spans the row, so the count sits at its end.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A Wrap, not a Row: at large text sizes the count moves under the
        // stage's name instead of pushing past the screen's edge (DL §8.6).
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.sm,
          children: [
            AppText(
              label,
              style: AppTypography.bodyMd,
              color: colors.textPrimary,
            ),
            AppText(
              '$done of $total done',
              style: AppTypography.numeric,
              color: colors.textSecondary,
            ),
          ],
        ),
        if (details.isNotEmpty)
          AppText(
            details.join(' · '),
            style: AppTypography.bodySm,
            color: colors.textSecondary,
          ),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'in progress', size: Size(360, 64), wrapper: previewWrapper)
Widget previewStageProgressRow() =>
    const StageProgressRow(label: 'Labels', done: 5, total: 7);

@Preview(name: 'with details', size: Size(360, 64), wrapper: previewWrapper)
Widget previewStageProgressRowDetails() => const StageProgressRow(
      label: 'Reading the file',
      done: 9,
      total: 12,
      details: ['1 failed', '2 skipped'],
    );
