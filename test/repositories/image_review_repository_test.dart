import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/image_review_mocks.dart';
import 'package:radiologist_helper/data/mocks/user_mocks.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';

void main() {
  group('MockImageReviewRepository', () {
    test('getReviews returns the mocks', () async {
      final reviews = await MockImageReviewRepository().getReviews();
      expect(reviews.map((r) => r.id), mockImageReviews.map((r) => r.id));
    });

    test('decide records the decision as decided, by the current user',
        () async {
      final repository = MockImageReviewRepository();
      final decided = await repository.decide(
        'review-01',
        outcome: ReviewOutcome.setView,
        view: ImageView.frontal,
        note: 'Second frontal film',
      );

      expect(decided.status, ReviewStatus.decided);
      expect(decided.decision!.outcome, ReviewOutcome.setView);
      expect(decided.decision!.view, ImageView.frontal);
      expect(decided.decision!.note, 'Second frontal film');
      expect(decided.decision!.decidedBy, mockCurrentUser.name);
      expect(decided.decision!.appliedAt, isNull);

      final reviews = await repository.getReviews();
      expect(
        reviews.firstWhere((r) => r.id == 'review-01').status,
        ReviewStatus.decided,
      );
    });

    test('changing an applied decision moves it back to decided', () async {
      final repository = MockImageReviewRepository();
      final changed = await repository.decide(
        'review-04',
        outcome: ReviewOutcome.unusable,
      );
      expect(changed.status, ReviewStatus.decided);
      expect(changed.decision!.appliedAt, isNull);
    });

    test('each instance starts from the mocks', () async {
      await MockImageReviewRepository()
          .decide('review-02', outcome: ReviewOutcome.unusable);

      final fresh = await MockImageReviewRepository().getReviews();
      expect(
        fresh.firstWhere((r) => r.id == 'review-02').status,
        ReviewStatus.pending,
      );
    });

    test('a view without setView is refused', () async {
      expect(
        MockImageReviewRepository().decide(
          'review-01',
          outcome: ReviewOutcome.unusable,
          view: ImageView.pa,
        ),
        throwsArgumentError,
      );
    });

    test('setView without a view is refused', () async {
      expect(
        MockImageReviewRepository()
            .decide('review-01', outcome: ReviewOutcome.setView),
        throwsArgumentError,
      );
    });

    test('an unknown review is refused', () async {
      expect(
        MockImageReviewRepository()
            .decide('nope', outcome: ReviewOutcome.unusable),
        throwsArgumentError,
      );
    });
  });
}
