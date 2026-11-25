import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';

void main() {
  group('RecordedLabels.namedView', () {
    test('header and dataset naming the same orientation name the header',
        () {
      const labels = RecordedLabels(
        viewPosition: ImageView.pa,
        orientation: ImageOrientation.frontal,
      );
      expect(labels.namedView, ImageView.pa);
    });

    test('a lateral header on a frontal dataset class names none', () {
      const labels = RecordedLabels(
        viewPosition: ImageView.ll,
        orientation: ImageOrientation.frontal,
      );
      expect(labels.namedView, isNull);
    });

    test('a missing header view names none', () {
      const labels = RecordedLabels(orientation: ImageOrientation.frontal);
      expect(labels.namedView, isNull);
    });

    test('a header with no dataset class names the header', () {
      // Every uploaded DICOM file: the header is its only label.
      const labels = RecordedLabels(viewPosition: ImageView.pa);
      expect(labels.namedView, ImageView.pa);
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

  group('ImageView.displayName', () {
    const expected = {
      ImageView.pa: 'PA',
      ImageView.ap: 'AP',
      ImageView.ll: 'Left lateral (LL)',
      ImageView.rl: 'Right lateral (RL)',
      ImageView.frontal: 'Frontal',
      ImageView.lateral: 'Lateral',
    };
    for (final view in ImageView.values) {
      test(view.name, () => expect(view.displayName, expected[view]));
    }
  });

  group('ViewModelCall.displayName', () {
    final expected = {
      0.75: 'Lateral, 75%',
      // Rounded down, so a call just under a threshold never reads as on it.
      0.899: 'Lateral, 89%',
      // Just under 57 once multiplied in floating point.
      0.57: 'Lateral, 57%',
      1.0: 'Lateral, 100%',
    };
    for (final MapEntry(key: probability, value: text) in expected.entries) {
      test('$probability reads "$text"', () {
        final ViewModelCall call =
            (view: ImageView.lateral, probability: probability);
        expect(call.displayName, text);
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
