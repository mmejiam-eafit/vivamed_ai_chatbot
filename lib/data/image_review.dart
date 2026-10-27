import 'package:radiologist_helper/data/case.dart';

/// Where a flagged image's review stands. The pipeline sets [pending] when it
/// flags the image, a radiologist's decision sets [decided], and the pipeline
/// sets [applied] once it has updated the image's embeddings and the search
/// indices. Until then the image is held back from similar cases. The app
/// never moves a review to [applied] itself; a later change of decision moves
/// it back to [decided].
enum ReviewStatus { pending, decided, applied }

/// Why the pipeline flagged an image instead of placing it.
enum ReviewReason {
  /// The view in the image file's header and the dataset's frontal/lateral
  /// class contradict each other.
  viewLabelsDisagree('The two view labels disagree'),

  /// The picture looks empty.
  imageBlank('The image looks blank');

  const ReviewReason(this.label);

  final String label;
}

/// What a radiologist decided: the image's view is [setView] to a chosen one,
/// the image is [unusable], or the recorded view is [confirmed] as right.
enum ReviewOutcome { setView, unusable, confirmed }

/// Named so as not to clash with Flutter's own `Orientation`.
enum ImageOrientation {
  frontal('Frontal'),
  lateral('Lateral');

  const ImageOrientation(this.label);

  final String label;
}

/// The views a file header records (PA, AP, LL, RL) plus the two a
/// radiologist can choose when only the orientation is certain.
enum ImageView {
  pa('PA', 'PA', ImageOrientation.frontal),
  ap('AP', 'AP', ImageOrientation.frontal),
  ll('LL', 'Left lateral', ImageOrientation.lateral),
  rl('RL', 'Right lateral', ImageOrientation.lateral),
  frontal('FRONTAL', 'Frontal', ImageOrientation.frontal),
  lateral('LATERAL', 'Lateral', ImageOrientation.lateral);

  const ImageView(this.code, this.label, this.orientation);

  /// The code the backend sends and stores.
  final String code;
  final String label;
  final ImageOrientation orientation;

  /// How the app writes it: header codes as codes, with the name where it
  /// isn't obvious; the two orientation-only views as words.
  String get displayName => switch (this) {
        pa || ap => code,
        ll || rl => '$label ($code)',
        frontal || lateral => label,
      };
}

/// The two labels an image arrives with. Either may be missing. Neither is
/// overwritten by a decision: they stay what the source said.
class RecordedLabels {
  const RecordedLabels({this.viewPosition, this.orientation});

  /// The view stored in the image file's header.
  final ImageView? viewPosition;

  /// The dataset's frontal/lateral class.
  final ImageOrientation? orientation;

  /// Both labels are present and say the same thing. Only then does "the
  /// recorded view is correct" name a single view.
  bool get agree =>
      viewPosition != null &&
      orientation != null &&
      viewPosition!.orientation == orientation;
}

class StudyImage {
  const StudyImage({
    required this.id,
    required this.url,
    required this.recorded,
  });

  final String id;
  final String url;
  final RecordedLabels recorded;
}

/// One section of a study's report, in display order.
class ReportSection {
  const ReportSection({required this.title, required this.text});

  final String title;
  final String text;
}

/// What a radiologist submits. The backend adds who decided and when.
typedef ReviewDecisionDraft = ({
  ReviewOutcome outcome,
  ImageView? view,
  String? note,
});

class ReviewDecision {
  const ReviewDecision({
    required this.outcome,
    required this.decidedBy,
    required this.decidedAt,
    this.view,
    this.note,
    this.appliedAt,
  });

  final ReviewOutcome outcome;

  /// The chosen view; set only when [outcome] is [ReviewOutcome.setView].
  final ImageView? view;
  final String? note;

  /// The radiologist's name as shown. The backend's own record of who
  /// decided is an opaque user key, which cannot be shown as it is.
  final String decidedBy;
  final DateTime decidedAt;

  /// When the pipeline applied the decision; null until then.
  final DateTime? appliedAt;
}

/// A review together with the study it belongs to, for a queue row.
typedef ReviewQueueItem = ({ImageReview review, CaseSummary caseSummary});

/// An image the pipeline flagged, with what a radiologist needs to decide
/// about it: the study's other images and its report.
class ImageReview {
  const ImageReview({
    required this.id,
    required this.status,
    required this.reason,
    required this.image,
    required this.caseId,
    required this.otherImages,
    required this.report,
    this.decision,
  });

  final String id;
  final ReviewStatus status;
  final ReviewReason reason;

  /// The flagged image.
  final StudyImage image;

  /// The study the image belongs to -- the backend's study id, which is a
  /// case id everywhere else in the app.
  final String caseId;

  /// The study's images other than the flagged one.
  final List<StudyImage> otherImages;
  final List<ReportSection> report;

  /// Null while [status] is [ReviewStatus.pending].
  final ReviewDecision? decision;

  /// Only the fields a decision changes.
  ImageReview copyWith({ReviewStatus? status, ReviewDecision? decision}) =>
      ImageReview(
        id: id,
        status: status ?? this.status,
        reason: reason,
        image: image,
        caseId: caseId,
        otherImages: otherImages,
        report: report,
        decision: decision ?? this.decision,
      );
}

/// How a study's held-back reviews read in a list: "1 awaiting review",
/// "1 processing", or both. Plain words, never a status color: a worklist row
/// also carries severity (DL D-022). Empty when nothing is held back.
String heldBackSummary(List<ImageReview> reviews) {
  final awaiting =
      reviews.where((r) => r.status == ReviewStatus.pending).length;
  final processing =
      reviews.where((r) => r.status == ReviewStatus.decided).length;
  return [
    if (awaiting > 0) '$awaiting awaiting review',
    if (processing > 0) '$processing processing',
  ].join(', ');
}
