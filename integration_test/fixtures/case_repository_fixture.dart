import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';

import 'fixture_result.dart';

/// Each method's result is configured independently -- a test for one
/// method leaves the others unconfigured (`null`), which throws loudly if
/// a page unexpectedly calls one it didn't set up for.
/// Mutable -- a test can reassign a result between calls without
/// re-overriding the provider.
class CaseRepositoryFixture implements CaseRepository {
  CaseRepositoryFixture({
    this.getCasesResult,
    this.getCaseDetailResult,
    this.getSimilarCasesResult,
  });

  FixtureResult<List<CaseSummary>>? getCasesResult;
  FixtureResult<CaseDetail>? getCaseDetailResult;
  FixtureResult<List<CaseSummary>>? getSimilarCasesResult;

  @override
  Future<List<CaseSummary>> getCases() =>
      getCasesResult?.resolve() ?? _unconfigured('getCases');

  @override
  Future<CaseDetail> getCaseDetail(String caseId) =>
      getCaseDetailResult?.resolve() ?? _unconfigured('getCaseDetail');

  @override
  Future<List<CaseSummary>> getSimilarCases(String caseId) =>
      getSimilarCasesResult?.resolve() ?? _unconfigured('getSimilarCases');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'CaseRepositoryFixture.$method not configured for this test');
