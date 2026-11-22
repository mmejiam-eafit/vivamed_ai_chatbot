import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_checkbox.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// One failed processing step, selectable for a retry or a discard. The
/// element's name, the stage and why it failed, and when. No status color:
/// every row in the list has failed, so its words say why (DL D-023).
///
/// The whole row is one control to assistive technology: a checkbox whose
/// label is the row's text. A tap anywhere on it toggles it; keyboard focus
/// stays on the checkbox, so the row is one stop, not two.
class FailureRow extends StatelessWidget {
  const FailureRow({
    super.key,
    required this.itemName,
    required this.stageLabel,
    required this.message,
    required this.meta,
    required this.selected,
    required this.onSelectedChanged,
  });

  /// The pipeline's name for the element: an identifier, so it never
  /// truncates (DL D-009).
  final String itemName;
  final String stageLabel;
  final String message;

  /// When it failed, and how often it was tried, already worded.
  final String meta;
  final bool selected;

  /// Null disables the row, e.g. while an action on the list is running.
  final ValueChanged<bool>? onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onSelectedChanged = this.onSelectedChanged;
    return MergeSemantics(
      child: InkWell(
        onTap: onSelectedChanged == null
            ? null
            : () => onSelectedChanged(!selected),
        canRequestFocus: false,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderButton,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCheckbox(value: selected, onChanged: onSelectedChanged),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  // Lines the name up with the middle of the checkbox.
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        itemName,
                        style: AppTypography.mono,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        '$stageLabel: $message',
                        style: AppTypography.bodyMd,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        meta,
                        style: AppTypography.bodySm,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'unselected', size: Size(390, 120), wrapper: previewWrapper)
Widget previewFailureRow() => FailureRow(
      itemName: 'img-7f3a23',
      stageLabel: 'Labels',
      message: 'A model could not be loaded. Try again later.',
      meta: 'Tried 4 times · 2026-11-22 10:15 UTC',
      selected: false,
      onSelectedChanged: (_) {},
    );

@Preview(name: 'selected', size: Size(390, 120), wrapper: previewWrapper)
Widget previewFailureRowSelected() => FailureRow(
      itemName: 'img-7f3a23',
      stageLabel: 'Reading the file',
      message: 'The image is in a format the pipeline cannot read yet.',
      meta: '2026-11-22 10:14 UTC',
      selected: true,
      onSelectedChanged: (_) {},
    );
