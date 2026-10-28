import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';

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

class MockCaseRepository implements CaseRepository {
  @override
  Future<List<CaseSummary>> getCases() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockCases;
  }

  @override
  Future<CaseDetail> getCaseDetail(String caseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final caseSummary = mockCases.firstWhere((c) => c.id == caseId);
    return CaseDetail(
      caseSummary: caseSummary,
      imageUrl: mockCaseImageUrlFor(caseId),
    );
  }

  @override
  Future<SimilarCases> getSimilarCases(String caseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final basis = mockSimilarCasesBasisFor(caseId);
    return SimilarCases(
      // With every image held back there is nothing to search with.
      cases: basis.used == 0
          ? const []
          : mockCases.where((c) => c.id != caseId).take(3).toList(),
      imagesUsed: basis.used,
      imagesTotal: basis.total,
      imagesHeldBack: basis.heldBack,
    );
  }
}
