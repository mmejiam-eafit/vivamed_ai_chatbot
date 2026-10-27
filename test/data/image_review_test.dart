import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';

void main() {
  group('RecordedLabels.agree', () {
    test('header and dataset name the same orientation', () {
      const labels = RecordedLabels(
        viewPosition: ImageView.pa,
        orientation: ImageOrientation.frontal,
      );
      expect(labels.agree, isTrue);
    });

    test('a lateral header on a frontal dataset class disagrees', () {
      const labels = RecordedLabels(
        viewPosition: ImageView.ll,
        orientation: ImageOrientation.frontal,
      );
      expect(labels.agree, isFalse);
    });

    test('a missing header view does not agree', () {
      const labels = RecordedLabels(orientation: ImageOrientation.frontal);
      expect(labels.agree, isFalse);
    });

    test('a missing dataset class does not agree', () {
      const labels = RecordedLabels(viewPosition: ImageView.pa);
      expect(labels.agree, isFalse);
    });
  });

  group('ImageView', () {
    const expected = {
      ImageView.pa: ('PA', ImageOrientation.frontal),
      ImageView.ap: ('AP', ImageOrientation.frontal),
      ImageView.ll: ('LL', ImageOrientation.lateral),
      ImageView.rl: ('RL', ImageOrientation.lateral),
      ImageView.frontal: ('FRONTAL', ImageOrientation.frontal),
      ImageView.lateral: ('LATERAL', ImageOrientation.lateral),
    };
    for (final view in ImageView.values) {
      test('${view.name} has the backend code and orientation', () {
        expect(view.code, expected[view]!.$1);
        expect(view.orientation, expected[view]!.$2);
      });
    }
  });

  group('ImageReview.copyWith', () {
    const pending = ImageReview(
      id: 'r1',
      status: ReviewStatus.pending,
      reason: ReviewReason.imageBlank,
      image: StudyImage(id: 'i1', url: 'u', recorded: RecordedLabels()),
      caseId: 'case-1',
      otherImages: [],
      report: [],
    );

    test('changes status and decision, keeps everything else', () {
      final decision = ReviewDecision(
        outcome: ReviewOutcome.unusable,
        decidedBy: 'Dr. A',
        decidedAt: DateTime.utc(2026),
      );
      final decided =
          pending.copyWith(status: ReviewStatus.decided, decision: decision);

      expect(decided.status, ReviewStatus.decided);
      expect(decided.decision, same(decision));
      expect(decided.id, 'r1');
      expect(decided.reason, ReviewReason.imageBlank);
      expect(decided.caseId, 'case-1');
    });

    test('with no arguments keeps status and decision', () {
      final copy = pending.copyWith();
      expect(copy.status, ReviewStatus.pending);
      expect(copy.decision, isNull);
    });
  });
}
