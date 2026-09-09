import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// What kind of value this field holds — decides voice and whether it may
/// ever truncate (design_language.md §4.2, §4.6).
enum MetadataValueKind {
  /// Short, non-clinical labels (a role, a setting). May clamp.
  text,

  /// A study UID, accession number, or anything a clinician might
  /// transcribe verbatim. Renders in the mono voice. Never truncates.
  identifier,

  /// A measurement, date, or confidence value. Renders in the numeric
  /// voice (tabular figures). Never truncates.
  numeric,
}

class MetadataField extends StatelessWidget {
  const MetadataField({
    super.key,
    required this.label,
    required this.value,
    this.valueKind = MetadataValueKind.text,
  });

  final String label;
  final String value;
  final MetadataValueKind valueKind;

  static TextStyle _styleFor(MetadataValueKind kind) => switch (kind) {
        MetadataValueKind.text => AppTypography.bodyMd,
        MetadataValueKind.identifier => AppTypography.mono,
        MetadataValueKind.numeric => AppTypography.numeric,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final neverTruncates = valueKind != MetadataValueKind.text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: AppTypography.labelMd,
          color: colors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            value,
            style: _styleFor(valueKind),
            color: colors.textPrimary,
            textAlign: TextAlign.end,
            overflow: neverTruncates ? null : TextOverflow.ellipsis,
            maxLines: neverTruncates ? null : 1,
          ),
        ),
      ],
    );
  }
}
