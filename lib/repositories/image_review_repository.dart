import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/image_review_mocks.dart';
import 'package:radiologist_helper/data/mocks/user_mocks.dart';

abstract class ImageReviewRepository {
  /// Every review, in any status: the review queue, and what the Studies list,
  /// Study Review and the navigation count read.
  Future<List<ImageReview>> getReviews();

  /// Records a radiologist's decision and returns the review as the backend
  /// now holds it: [ReviewStatus.decided], with who decided and when. [view]
  /// is set exactly when [outcome] is [ReviewOutcome.setView].
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  });
}

class MockImageReviewRepository implements ImageReviewRepository {
  /// Each instance starts from the mocks, so a decision made in one
  /// `ProviderScope` (one test, one integration scenario) never leaks into
  /// the next.
  MockImageReviewRepository() : _reviews = List.of(mockImageReviews);

  final List<ImageReview> _reviews;

  @override
  Future<List<ImageReview>> getReviews() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_reviews);
  }

  @override
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if ((outcome == ReviewOutcome.setView) != (view != null)) {
      throw ArgumentError('A view is chosen exactly when setting the view');
    }
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index < 0) throw ArgumentError.value(reviewId, 'reviewId');
    final decided = _reviews[index].copyWith(
      status: ReviewStatus.decided,
      decision: ReviewDecision(
        outcome: outcome,
        view: view,
        note: note,
        decidedBy: mockCurrentUser.name,
        decidedAt: DateTime.now().toUtc(),
      ),
    );
    _reviews[index] = decided;
    return decided;
  }
}
