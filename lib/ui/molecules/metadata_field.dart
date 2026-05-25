import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class MetadataField extends StatelessWidget {
  const MetadataField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          label,
          style: AppTypography.labelMd,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            value,
            style: AppTypography.bodyMd,
            color: AppColors.textPrimary,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'single field', size: Size(320, 32), wrapper: previewWrapper)
Widget previewMetadataFieldSingle() =>
    const MetadataField(label: 'Modality', value: 'CT');

@Preview(name: 'long value truncated', size: Size(240, 32), wrapper: previewWrapper)
Widget previewMetadataFieldLong() => const MetadataField(
      label: 'Study UID',
      value: '1.2.840.10008.5.1.4.1.1.2.1234567890',
    );

@Preview(name: 'stacked fields', size: Size(320, 96), wrapper: previewWrapper)
Widget previewMetadataFieldStack() => const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MetadataField(label: 'Patient', value: 'Anonymous-7812'),
        SizedBox(height: AppSpacing.sm),
        MetadataField(label: 'Date', value: '2026-05-01'),
        SizedBox(height: AppSpacing.sm),
        MetadataField(label: 'Modality', value: 'CT'),
      ],
    );
