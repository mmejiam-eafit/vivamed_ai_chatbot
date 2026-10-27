import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/captioned_image.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';
import 'package:radiologist_helper/ui/organisms/image_review_panel.dart';
import 'package:radiologist_helper/ui/templates/image_review_template.dart';

/// One flagged image, for a radiologist to decide about. Reached from the
/// review queue and from Study Review.
class ImageReviewPage extends ConsumerStatefulWidget {
  const ImageReviewPage({super.key, required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<ImageReviewPage> createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends ConsumerState<ImageReviewPage> {
  bool _saving = false;
  String? _error;

  /// The image's recorded labels, as a caption under it.
  static String _caption(StudyImage image, {bool flagged = false}) {
    final recorded = image.recorded;
    return [
      if (flagged) 'Flagged',
      'Header ${recorded.viewPosition?.code ?? 'not recorded'}',
      'Dataset ${recorded.orientation?.label ?? 'not recorded'}',
    ].join(' · ');
  }

  Future<void> _save(ReviewDecisionDraft draft, String caseId) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(imageReviewServiceProvider).decide(
            widget.reviewId,
            outcome: draft.outcome,
            view: draft.view,
            note: draft.note,
          );
      // Wait for the decided review before leaving the saving state, so the
      // form never reopens against the old one in between.
      ref.invalidate(imageReviewsProvider);
      ref.invalidate(similarCasesProvider(caseId));
      await ref.read(imageReviewsProvider.future);
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save the decision: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  ImageReviewTemplate _message(AppBar appBar, Widget message) =>
      ImageReviewTemplate(
        appBar: appBar,
        flaggedImage: const SizedBox.shrink(),
        otherImages: const [],
        reviewPanel: Center(child: message),
        reportSections: const [],
      );

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Image review'));
    final service = ref.watch(imageReviewServiceProvider);
    final user = ref.watch(currentUserProvider).value;

    return ref.watch(imageReviewsProvider).when(
          data: (reviews) {
            final review =
                reviews.where((r) => r.id == widget.reviewId).firstOrNull;
            if (review == null) {
              return _message(
                appBar,
                const AppText('This review is no longer in the queue.'),
              );
            }
            return ImageReviewTemplate(
              appBar: appBar,
              flaggedImage: CaptionedImage(
                url: review.image.url,
                caption: _caption(review.image, flagged: true),
              ),
              otherImages: [
                for (final image in review.otherImages)
                  CaptionedImage(url: image.url, caption: _caption(image)),
              ],
              // Keyed on the decision, so a saved one resets the panel to its
              // summary; a failed save keeps the radiologist's choice.
              reviewPanel: ImageReviewPanel(
                key: ValueKey(review.decision?.decidedAt),
                review: review,
                canDecide: user != null && service.canDecide(user),
                isSaving: _saving,
                errorMessage: _error,
                onSave: (draft) => _save(draft, review.caseId),
              ),
              reportSections: review.report.isEmpty
                  ? const [
                      SectionCard(
                        title: 'Report',
                        child: AppText('No report for this study.'),
                      ),
                    ]
                  : [
                      for (final section in review.report)
                        SectionCard(
                          title: section.title,
                          child: AppText(section.text),
                        ),
                    ],
            );
          },
          loading: () => _message(appBar, const AppLoadingIndicator()),
          error: (error, stackTrace) =>
              _message(appBar, AppText('Could not load the review: $error')),
        );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewImageReviewPageNarrow() =>
    const ImageReviewPage(reviewId: 'review-01');

@Preview(name: 'wide', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewImageReviewPageWide() =>
    const ImageReviewPage(reviewId: 'review-01');
