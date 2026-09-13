import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/image_thumbnail.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';

class StudyMetadataField {
  const StudyMetadataField({
    required this.label,
    required this.value,
    this.valueKind = MetadataValueKind.text,
  });

  final String label;
  final String value;
  final MetadataValueKind valueKind;
}

class StudyInfoCard extends StatelessWidget {
  const StudyInfoCard({
    super.key,
    required this.title,
    required this.fields,
    this.thumbnailUrl,
    this.thumbnailBadge,
    this.onThumbnailTap,
    this.onTap,
    this.focusNode,
  });

  final String title;
  final List<StudyMetadataField> fields;
  final String? thumbnailUrl;
  final String? thumbnailBadge;
  final VoidCallback? onThumbnailTap;

  /// The whole card, distinct from [onThumbnailTap] -- opens the study.
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  Widget _content(AppColorsData colors) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        // SingleChildScrollView prevents RenderFlex overflow when the card
        // is placed in a parent that constrains height below the content's
        // natural size.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      title,
                      style: AppTypography.headingSm,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (thumbnailUrl != null) ...[
                    const SizedBox(width: AppSpacing.lg),
                    ImageThumbnail(
                      url: thumbnailUrl!,
                      badgeLabel: thumbnailBadge,
                      onTap: onThumbnailTap,
                    ),
                  ],
                ],
              ),
              if (fields.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ...fields.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: MetadataField(
                      label: f.label,
                      value: f.value,
                      valueKind: f.valueKind,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: colors.border),
        boxShadow: AppElevation.card,
      ),
      child: _content(colors),
    );

    if (onTap == null) return card;

    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.card + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        focusNode: focusNode,
        hoverColor:
            colors.textPrimary.withValues(alpha: AppInteraction.hoverOverlayOpacity),
        borderRadius: AppRadius.borderCard,
        child: card,
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewFields = [
  StudyMetadataField(label: 'Patient', value: 'Anonymous-7812'),
  StudyMetadataField(
    label: 'Date',
    value: '2026-05-01',
    valueKind: MetadataValueKind.numeric,
  ),
  StudyMetadataField(label: 'Modality', value: 'CT'),
  StudyMetadataField(
    label: 'Study UID',
    value: '1.2.840.10008.5.1.4.1.1.2',
    valueKind: MetadataValueKind.identifier,
  ),
];

@Preview(name: 'with thumbnail', size: Size(360, 220), wrapper: previewWrapper)
Widget previewStudyInfoCardWithThumb() => const StudyInfoCard(
      title: 'Chest CT — Posterior-Anterior',
      fields: _previewFields,
      thumbnailUrl: 'https://picsum.photos/80/80',
      thumbnailBadge: '3',
    );

@Preview(name: 'without thumbnail', size: Size(360, 180), wrapper: previewWrapper)
Widget previewStudyInfoCardNoThumb() => const StudyInfoCard(
      title: 'Chest X-Ray',
      fields: _previewFields,
    );

@Preview(name: 'minimal', size: Size(360, 100), wrapper: previewWrapper)
Widget previewStudyInfoCardMinimal() => const StudyInfoCard(
      title: 'Abdominal CT',
      fields: [StudyMetadataField(label: 'Modality', value: 'CT')],
    );
