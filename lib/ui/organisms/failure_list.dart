import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/atoms/app_checkbox.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/failure_row.dart';

/// A study's failed processing steps, each selectable, with a "select all"
/// over them. What to do with the selection is the action bar's; this list
/// only reports it.
class FailureList extends StatelessWidget {
  const FailureList({
    super.key,
    required this.failures,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<ProcessingFailure> failures;

  /// The step ids selected; ids not in [failures] are ignored.
  final Set<String> selectedIds;

  /// Null disables the selection, e.g. while an action on it is running.
  final ValueChanged<Set<String>>? onSelectionChanged;

  static String _heading(int count) =>
      count == 1 ? '1 failed item' : '$count failed items';

  static String _timestamp(DateTime time) {
    final t = time.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)} UTC';
  }

  /// Attempts only when the pipeline retried on its own: a single attempt
  /// says nothing the failure itself doesn't.
  static String _meta(ProcessingFailure failure) => failure.attempts > 1
      ? 'Tried ${failure.attempts} times · ${_timestamp(failure.failedAt)}'
      : _timestamp(failure.failedAt);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onSelectionChanged = this.onSelectionChanged;
    final ids = {for (final f in failures) f.stepId};
    final selected = selectedIds.intersection(ids);
    final allSelected = selected.length == ids.length
        ? true
        : selected.isEmpty
            ? false
            : null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderCard,
        boxShadow: AppElevation.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: failures.isEmpty
          ? AppText(
              'No failed items.',
              style: AppTypography.bodyMd,
              color: colors.textSecondary,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppCheckbox(
                      value: allSelected,
                      semanticLabel: 'Select all',
                      onChanged: onSelectionChanged == null
                          ? null
                          : (all) => onSelectionChanged(all ? ids : {}),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        _heading(failures.length),
                        style: AppTypography.headingSm,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                for (final failure in failures)
                  FailureRow(
                    internalName: failure.internalName,
                    stageLabel: failure.stage.label,
                    message: failure.code.message,
                    meta: _meta(failure),
                    selected: selected.contains(failure.stepId),
                    onSelectedChanged: onSelectionChanged == null
                        ? null
                        : (isSelected) => onSelectionChanged(isSelected
                            ? {...selected, failure.stepId}
                            : ({...selected}..remove(failure.stepId))),
                  ),
              ],
            ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

final _previewFailures = [
  ProcessingFailure(
    stepId: 's1',
    stage: ProcessingStage.prediction,
    internalName: 'img-7f3a22',
    code: ProcessingErrorCode.modelUnavailable,
    attempts: 4,
    failedAt: DateTime.utc(2026, 11, 22, 10, 15, 40),
    canRetry: true,
  ),
  ProcessingFailure(
    stepId: 's2',
    stage: ProcessingStage.intake,
    internalName: 'img-7f3a23',
    code: ProcessingErrorCode.unsupportedPixelData,
    attempts: 1,
    failedAt: DateTime.utc(2026, 11, 22, 10, 14, 3),
    canRetry: true,
  ),
];

@Preview(name: 'one selected', size: Size(390, 360), wrapper: previewWrapper)
Widget previewFailureList() => FailureList(
      failures: _previewFailures,
      selectedIds: const {'s1'},
      onSelectionChanged: (_) {},
    );

@Preview(name: 'empty', size: Size(390, 120), wrapper: previewWrapper)
Widget previewFailureListEmpty() => FailureList(
      failures: const [],
      selectedIds: const {},
      onSelectionChanged: (_) {},
    );
