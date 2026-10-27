import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';

/// One choice in the decision form. A record, so two choices with the same
/// outcome and view are equal -- what `RadioGroup` compares.
typedef _Choice = ({ReviewOutcome outcome, ImageView? view});

/// Why an image was flagged, what its two labels say, and the radiologist's
/// decision about it: a form while there is none (or while it is being
/// changed), otherwise who decided what and when.
///
/// Local state only -- the choice, the note, and whether the form is open.
/// The page resets it once a saved decision comes back, by keying it on that
/// decision.
class ImageReviewPanel extends StatefulWidget {
  const ImageReviewPanel({
    super.key,
    required this.review,
    required this.canDecide,
    required this.onSave,
    this.isSaving = false,
    this.errorMessage,
  });

  final ImageReview review;

  /// False for anyone but a radiologist: the review is shown read-only.
  final bool canDecide;
  final ValueChanged<ReviewDecisionDraft> onSave;
  final bool isSaving;

  /// Why the last save failed; the form stays open with the choice kept.
  final String? errorMessage;

  @override
  State<ImageReviewPanel> createState() => _ImageReviewPanelState();
}

class _ImageReviewPanelState extends State<ImageReviewPanel> {
  /// The radiologist chose Change decision on an existing one.
  bool _changing = false;

  /// Worked out on every build rather than once: who may decide can arrive
  /// after the review does (the signed-in user loads separately), and a
  /// panel first built read-only must still open its form once it does.
  bool get _showForm =>
      widget.canDecide && (widget.review.decision == null || _changing);
  late _Choice? _choice = _choiceOf(widget.review.decision);
  late final _note = TextEditingController(
    text: widget.review.decision?.note ?? '',
  );

  static _Choice? _choiceOf(ReviewDecision? decision) => decision == null
      ? null
      : (outcome: decision.outcome, view: decision.view);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  static String _outcomeText(ReviewDecision decision) =>
      switch (decision.outcome) {
        ReviewOutcome.setView => 'View set to ${decision.view!.displayName}',
        ReviewOutcome.unusable => 'Marked unusable',
        ReviewOutcome.confirmed => 'Recorded view confirmed',
      };

  static String _timestamp(DateTime time) {
    final t = time.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)} UTC';
  }

  /// Which recorded label a view choice matches, so either one is a single
  /// tap away: the header's exact view, or the dataset's orientation.
  static String? _sourceOf(ImageView view, RecordedLabels recorded) {
    final sources = [
      if (recorded.viewPosition == view) 'File header',
      if ((view == ImageView.frontal &&
              recorded.orientation == ImageOrientation.frontal) ||
          (view == ImageView.lateral &&
              recorded.orientation == ImageOrientation.lateral))
        'Dataset',
    ];
    return sources.isEmpty ? null : sources.join(' · ');
  }

  void _save() {
    final choice = _choice!;
    final note = _note.text.trim();
    widget.onSave((
      outcome: choice.outcome,
      view: choice.view,
      note: note.isEmpty ? null : note,
    ));
  }

  void _cancel() => setState(() {
        _changing = false;
        _choice = _choiceOf(widget.review.decision);
        _note.text = widget.review.decision?.note ?? '';
      });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final review = widget.review;
    final recorded = review.image.recorded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ReviewStatusChip(status: review.status),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Why it was flagged',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                review.reason.label,
                style: AppTypography.bodyMd,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              MetadataField(
                label: 'File header',
                value: recorded.viewPosition == null
                    ? 'Not recorded'
                    : recorded.viewPosition!.displayName,
                valueKind: MetadataValueKind.identifier,
              ),
              // Both labels are transcribed, so neither may truncate (DL §4.6).
              MetadataField(
                label: 'Dataset',
                value: recorded.orientation?.label ?? 'Not recorded',
                valueKind: MetadataValueKind.identifier,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: 'Decision',
          child: _showForm ? _form(colors, recorded) : _summary(colors),
        ),
      ],
    );
  }

  Widget _option(
    AppColorsData colors,
    _Choice value,
    String title, {
    String? subtitle,
  }) {
    return RadioListTile<_Choice>(
      value: value,
      enabled: !widget.isSaving,
      activeColor: colors.interactivePrimary,
      contentPadding: EdgeInsets.zero,
      title: AppText(
        title,
        style: AppTypography.bodyMd,
        color: colors.textPrimary,
      ),
      subtitle: subtitle == null
          ? null
          : AppText(
              subtitle,
              style: AppTypography.bodySm,
              color: colors.textSecondary,
            ),
    );
  }

  Widget _form(AppColorsData colors, RecordedLabels recorded) {
    final hasDecision = widget.review.decision != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RadioGroup<_Choice>(
          groupValue: _choice,
          onChanged: (choice) => setState(() => _choice = choice),
          // The tiles' ink would otherwise paint on the Material behind
          // SectionCard's background and never be seen, as in
          // ThemeModeSelector. Transparent: an ink surface, nothing visible.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (final view in ImageView.values)
                  _option(
                    colors,
                    (outcome: ReviewOutcome.setView, view: view),
                    view.displayName,
                    subtitle: _sourceOf(view, recorded),
                  ),
                _option(
                  colors,
                  (outcome: ReviewOutcome.unusable, view: null),
                  'Unusable',
                  subtitle: 'Left out of findings and similar cases',
                ),
                // Only when the labels agree does "recorded" name one view;
                // otherwise the radiologist picks the view itself.
                if (recorded.agree)
                  _option(
                    colors,
                    (outcome: ReviewOutcome.confirmed, view: null),
                    'Recorded view is correct '
                    '(${recorded.viewPosition!.displayName})',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: _note,
          hintText: 'Note (optional)',
          enabled: !widget.isSaving,
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusBanner(
            message: widget.errorMessage!,
            variant: StatusBannerVariant.error,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (hasDecision)
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.ghost,
                onPressed: widget.isSaving ? null : _cancel,
              ),
            AppButton(
              label: 'Save decision',
              isLoading: widget.isSaving,
              onPressed: _choice == null || widget.isSaving ? null : _save,
            ),
          ],
        ),
      ],
    );
  }

  Widget _summary(AppColorsData colors) {
    final decision = widget.review.decision;
    if (decision == null) {
      return AppText(
        'Waiting for a radiologist. Only radiologists can record a decision.',
        style: AppTypography.bodyMd,
        color: colors.textSecondary,
      );
    }
    // The decision and its note wrap rather than clamp to a line: both are
    // read and acted on (DL §4.6).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          _outcomeText(decision),
          style: AppTypography.bodyMd,
          color: colors.textPrimary,
        ),
        if (decision.note != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            'Note: ${decision.note}',
            style: AppTypography.bodyMd,
            color: colors.textSecondary,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        MetadataField(label: 'Decided by', value: decision.decidedBy),
        MetadataField(
          label: 'Decided at',
          value: _timestamp(decision.decidedAt),
          valueKind: MetadataValueKind.numeric,
        ),
        if (decision.appliedAt != null)
          MetadataField(
            label: 'Applied at',
            value: _timestamp(decision.appliedAt!),
            valueKind: MetadataValueKind.numeric,
          ),
        const SizedBox(height: AppSpacing.md),
        if (widget.canDecide)
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Change decision',
              variant: AppButtonVariant.secondary,
              onPressed: () => setState(() => _changing = true),
            ),
          )
        else
          AppText(
            'Only radiologists can change a decision.',
            style: AppTypography.bodySm,
            color: colors.textSecondary,
          ),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewPending = ImageReview(
  id: 'preview-1',
  status: ReviewStatus.pending,
  reason: ReviewReason.viewLabelsDisagree,
  image: StudyImage(
    id: 'preview-image-1',
    url: 'https://picsum.photos/seed/preview-review/800/800',
    recorded: RecordedLabels(
      viewPosition: ImageView.ll,
      orientation: ImageOrientation.frontal,
    ),
  ),
  caseId: 'preview-case',
  otherImages: [],
  report: [],
);

final _previewDecided = ImageReview(
  id: 'preview-2',
  status: ReviewStatus.decided,
  reason: ReviewReason.imageBlank,
  image: const StudyImage(
    id: 'preview-image-2',
    url: 'https://picsum.photos/seed/preview-review-2/800/800',
    recorded: RecordedLabels(
      viewPosition: ImageView.pa,
      orientation: ImageOrientation.frontal,
    ),
  ),
  caseId: 'preview-case',
  otherImages: const [],
  report: const [],
  decision: ReviewDecision(
    outcome: ReviewOutcome.confirmed,
    decidedBy: 'Dr. J. Okafor',
    decidedAt: DateTime.utc(2026, 10, 26, 15, 40),
  ),
);

@Preview(name: 'needs review', size: Size(360, 900), wrapper: previewWrapper)
Widget previewImageReviewPanelPending() => SingleChildScrollView(
      child: ImageReviewPanel(
        review: _previewPending,
        canDecide: true,
        onSave: (_) {},
      ),
    );

@Preview(name: 'processing', size: Size(360, 700), wrapper: previewWrapper)
Widget previewImageReviewPanelDecided() => SingleChildScrollView(
      child: ImageReviewPanel(
        review: _previewDecided,
        canDecide: true,
        onSave: (_) {},
      ),
    );

@Preview(name: 'read-only', size: Size(360, 500), wrapper: previewWrapper)
Widget previewImageReviewPanelReadOnly() => SingleChildScrollView(
      child: ImageReviewPanel(
        review: _previewPending,
        canDecide: false,
        onSave: (_) {},
      ),
    );
