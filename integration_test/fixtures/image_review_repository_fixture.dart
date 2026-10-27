import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';

import 'fixture_result.dart';

/// Each method's result is configured independently, as in
/// [CaseRepositoryFixture]; an unconfigured one throws loudly. Mutable -- a
/// test can reassign `getReviewsResult` before a decision, so the refetch
/// that follows it returns the decided review.
class ImageReviewRepositoryFixture implements ImageReviewRepository {
  ImageReviewRepositoryFixture({this.getReviewsResult, this.decideResult});

  FixtureResult<List<ImageReview>>? getReviewsResult;
  FixtureResult<ImageReview>? decideResult;

  @override
  Future<List<ImageReview>> getReviews() =>
      getReviewsResult?.resolve() ?? _unconfigured('getReviews');

  @override
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) =>
      decideResult?.resolve() ?? _unconfigured('decide');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'ImageReviewRepositoryFixture.$method not configured for this test');
