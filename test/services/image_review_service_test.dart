import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/image_review_mocks.dart';
import 'package:radiologist_helper/data/mocks/user_mocks.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/image_review_service.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

import '../support/fake_image_review_repository.dart';

ImageReview _review(String id, ReviewStatus status, {String caseId = 'c1'}) =>
    ImageReview(
      id: id,
      status: status,
      reason: ReviewReason.imageBlank,
      image: const StudyImage(id: 'i', url: 'u', recorded: RecordedLabels()),
      caseId: caseId,
      otherImages: const [],
      report: const [],
    );

CaseSummary _case(String id) => CaseSummary(
      id: id,
      title: 'Study $id',
      patient: 'Anonymous',
      modality: 'CXR',
      date: DateTime(2026),
      confidence: 0.5,
      severity: SeverityLevel.normal,
    );

class _CasesRepository implements CaseRepository {
  _CasesRepository(this.cases);

  final List<CaseSummary> cases;

  @override
  Future<List<CaseSummary>> getCases() async => cases;

  @override
  Future<CaseDetail> getCaseDetail(String caseId) => throw UnimplementedError();

  @override
  Future<List<CaseSummary>> getSimilarCases(String caseId) =>
      throw UnimplementedError();
}

void main() {
  group('ImageReviewService', () {
    test('getReviews puts needs review first, then processing, then applied, '
        'keeping the order within a status', () async {
      final service = ImageReviewService(FakeImageReviewRepository(reviews: [
        _review('a1', ReviewStatus.applied),
        _review('d1', ReviewStatus.decided),
        _review('p1', ReviewStatus.pending),
        _review('d2', ReviewStatus.decided),
        _review('p2', ReviewStatus.pending),
      ]));

      final reviews = await service.getReviews();

      expect(reviews.map((r) => r.id), ['p1', 'p2', 'd1', 'd2', 'a1']);
    });

    test('decide passes the decision through to the repository', () async {
      final repository = FakeImageReviewRepository();
      final service = ImageReviewService(repository);

      final decided = await service.decide(
        'review-01',
        outcome: ReviewOutcome.setView,
        view: ImageView.frontal,
        note: 'n',
      );

      expect(decided.status, ReviewStatus.decided);
      expect(decided.decision!.view, ImageView.frontal);
      expect(decided.decision!.note, 'n');
    });

    test('a radiologist can decide', () {
      final service = ImageReviewService(FakeImageReviewRepository());
      expect(service.canDecide(mockCurrentUser), isTrue);
    });

    test('another role cannot decide', () {
      final service = ImageReviewService(FakeImageReviewRepository());
      const technologist = UserProfile(
        name: 'T. Lee',
        role: 'Technologist',
        email: 't@hospital.org',
        initials: 'TL',
      );
      expect(service.canDecide(technologist), isFalse);
    });

    test('pendingCount counts only reviews that need review', () {
      final service = ImageReviewService(FakeImageReviewRepository());
      expect(service.pendingCount(mockImageReviews), 2);
    });

    test('heldBackByCase groups needs review and processing by case, '
        'leaving applied out', () {
      final service = ImageReviewService(FakeImageReviewRepository());

      final byCase = service.heldBackByCase([
        _review('p1', ReviewStatus.pending, caseId: 'c1'),
        _review('d1', ReviewStatus.decided, caseId: 'c1'),
        _review('a1', ReviewStatus.applied, caseId: 'c2'),
      ]);

      expect(byCase.keys, ['c1']);
      expect(byCase['c1']!.map((r) => r.id), ['p1', 'd1']);
    });

    test('queue joins each review to its case, in order', () {
      final service = ImageReviewService(FakeImageReviewRepository());

      final queue = service.queue(
        [_review('r1', ReviewStatus.pending, caseId: 'c2')],
        [_case('c1'), _case('c2')],
      );

      expect(queue.single.review.id, 'r1');
      expect(queue.single.caseSummary.id, 'c2');
    });

    test('queue throws for a review whose case is missing', () {
      final service = ImageReviewService(FakeImageReviewRepository());
      expect(
        () => service.queue([_review('r1', ReviewStatus.pending)], const []),
        throwsStateError,
      );
    });
  });

  group('review providers', () {
    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          imageReviewRepositoryProvider
              .overrideWithValue(FakeImageReviewRepository()),
          caseRepositoryProvider.overrideWithValue(
            _CasesRepository([_case('case-6'), _case('case-7'), _case('case-8')]),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('the pending count is 0 while the reviews load, then counts them',
        () async {
      final container = makeContainer();
      expect(container.read(pendingReviewCountProvider), 0);

      await container.read(imageReviewsProvider.future);

      expect(container.read(pendingReviewCountProvider), 2);
    });

    test('held-back reviews by case are empty while loading, then grouped',
        () async {
      final container = makeContainer();
      expect(container.read(heldBackReviewsByCaseProvider), isEmpty);

      await container.read(imageReviewsProvider.future);

      final byCase = container.read(heldBackReviewsByCaseProvider);
      expect(byCase.keys, unorderedEquals(['case-6', 'case-7', 'case-8']));
      expect(byCase['case-8']!.map((r) => r.id), ['review-02']);
    });

    test('the queue lists every review with its case', () async {
      final container = makeContainer();

      final queue = await container.read(reviewQueueProvider.future);

      expect(queue.map((item) => item.review.id),
          ['review-01', 'review-02', 'review-03', 'review-04']);
      expect(queue.first.caseSummary.id, 'case-7');
    });
  });
}
