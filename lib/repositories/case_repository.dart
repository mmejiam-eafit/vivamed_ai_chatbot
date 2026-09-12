import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';

abstract class CaseRepository {
  Future<List<CaseSummary>> getCases();

  /// Case + image only -- findings are a separate endpoint/repository
  /// ([FindingsRepository]), not merged in here.
  Future<CaseDetail> getCaseDetail(String caseId);
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
}
