import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';

abstract class CaseRepository {
  Future<List<CaseSummary>> getCases();

  /// Case + image only -- findings are a separate endpoint/repository
  /// ([FindingsRepository]), not merged in here.
  Future<CaseDetail> getCaseDetail(String caseId);

  /// A plausible real endpoint (`GET /cases/{id}/similar`), not a
  /// transformation of already-fetched data -- belongs here, not in
  /// `CaseService`. Only the backend knows which of the study's images the
  /// search used, so that comes back with the cases.
  Future<SimilarCases> getSimilarCases(String caseId);
}

/// Answers as the backend does: every study with the status it derives from
/// the pipeline's runs and the image reviews (its `GET /cases`).
class MockCaseRepository implements CaseRepository {
  MockCaseRepository(this._pipeline, this._reviews);

  final MockPipeline _pipeline;
  final ImageReviewRepository _reviews;

  static const _latency = Duration(milliseconds: 300);

  /// The seeded studies, then those uploaded through this scope's pipeline.
  List<CaseSummary> get _studies => [...mockCases, ..._pipeline.studies];

  CaseSummary _study(String caseId) =>
      _studies.firstWhere((c) => c.id == caseId);

  /// Waits as long as one request would, reading the reviews meanwhile.
  Future<List<ImageReview>> _reviewsAfterLatency() async {
    final (_, reviews) =
        await (Future<void>.delayed(_latency), _reviews.getReviews()).wait;
    return reviews;
  }

  CaseSummary _withStatus(CaseSummary study, List<ImageReview> reviews) {
    final facts = _pipeline.studyFacts(study.id);
    int count(ReviewStatus status) => reviews
        .where((r) => r.caseId == study.id && r.status == status)
        .length;
    return study.withStatus(
      status: deriveStudyStatus(
        facts,
        pendingReviews: count(ReviewStatus.pending),
        decidedReviews: count(ReviewStatus.decided),
      ),
      openFailures: facts.openFailures,
      activeRunId: facts.activeRunId,
    );
  }

  /// Answers with every study as it stands, then moves the active runs a
  /// wave on, as the pipeline's workers would have before the next read. So
  /// a new upload reads as queued first, like `getRun` does.
  @override
  Future<List<CaseSummary>> getCases() async {
    final reviews = await _reviewsAfterLatency();
    final studies = [
      for (final study in _studies) _withStatus(study, reviews),
    ];
    _pipeline.advanceActive();
    return studies;
  }

  @override
  Future<CaseDetail> getCaseDetail(String caseId) async {
    final reviews = await _reviewsAfterLatency();
    return CaseDetail(
      caseSummary: _withStatus(_study(caseId), reviews),
      imageUrl: mockCaseImageUrlFor(caseId),
    );
  }

  @override
  Future<SimilarCases> getSimilarCases(String caseId) async {
    final reviews = await _reviewsAfterLatency();
    final basis = mockSimilarCasesBasisFor(caseId);
    return SimilarCases(
      // With every image held back there is nothing to search with.
      cases: basis.used == 0
          ? const []
          : [
              for (final study
                  in mockCases.where((c) => c.id != caseId).take(3))
                _withStatus(study, reviews),
            ],
      imagesUsed: basis.used,
      imagesTotal: basis.total,
      imagesHeldBack: basis.heldBack,
    );
  }
}
