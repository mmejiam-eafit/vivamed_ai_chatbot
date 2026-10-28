import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/image_review_mocks.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';

/// [MockImageReviewRepository] without its 300 ms delay. A page test that
/// never shows a spinner (Home Hub) would otherwise end with that timer still
/// pending, which the test framework treats as a failure.
class FakeImageReviewRepository implements ImageReviewRepository {
  FakeImageReviewRepository({List<ImageReview>? reviews, this.decideError})
      : reviews = List.of(reviews ?? mockImageReviews);

  final List<ImageReview> reviews;

  /// When set, [decide] throws it instead of recording the decision.
  final Object? decideError;

  @override
  Future<List<ImageReview>> getReviews() async => List.unmodifiable(reviews);

  @override
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) async {
    if (decideError != null) throw decideError!;
    final index = reviews.indexWhere((r) => r.id == reviewId);
    final decided = reviews[index].copyWith(
      status: ReviewStatus.decided,
      decision: ReviewDecision(
        outcome: outcome,
        view: view,
        note: note,
        decidedBy: 'Dr. Test',
        decidedAt: DateTime.utc(2026, 10, 27, 9),
      ),
    );
    reviews[index] = decided;
    return decided;
  }
}
