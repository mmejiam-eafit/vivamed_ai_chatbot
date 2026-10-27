import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';

/// A review together with the study it belongs to, for a queue row.
typedef ReviewQueueItem = ({ImageReview review, CaseSummary caseSummary});

class ImageReviewService {
  ImageReviewService(this._repository);

  final ImageReviewRepository _repository;

  /// Needs review first, then processing, then applied -- the order the
  /// queue shows, so what still needs a radiologist is always on top. Within
  /// a status, the backend's order is kept.
  Future<List<ImageReview>> getReviews() async {
    final reviews = await _repository.getReviews();
    return [
      for (final status in ReviewStatus.values)
        ...reviews.where((r) => r.status == status),
    ];
  }

  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) =>
      _repository.decide(reviewId, outcome: outcome, view: view, note: note);

  /// Only radiologists decide; anyone else sees the review read-only. Until
  /// sign-in carries a real role, this reads the role the profile shows.
  bool canDecide(UserProfile user) => user.role == 'Radiologist';

  int pendingCount(List<ImageReview> reviews) =>
      reviews.where((r) => r.status == ReviewStatus.pending).length;

  /// The reviews still holding an image back (needs review or processing),
  /// keyed by case. A case with none is absent.
  Map<String, List<ImageReview>> heldBackByCase(List<ImageReview> reviews) {
    final byCase = <String, List<ImageReview>>{};
    for (final review in reviews) {
      if (review.status == ReviewStatus.applied) continue;
      byCase.putIfAbsent(review.caseId, () => []).add(review);
    }
    return byCase;
  }

  /// Each review with its study, in the reviews' order. A review whose study
  /// is not among [cases] is an inconsistency in the data, and throws rather
  /// than silently dropping a flagged image from the queue.
  List<ReviewQueueItem> queue(
    List<ImageReview> reviews,
    List<CaseSummary> cases,
  ) {
    final byId = {for (final c in cases) c.id: c};
    return [
      for (final review in reviews)
        (
          review: review,
          caseSummary: byId[review.caseId] ??
              (throw StateError('No case ${review.caseId} for ${review.id}')),
        ),
    ];
  }
}
