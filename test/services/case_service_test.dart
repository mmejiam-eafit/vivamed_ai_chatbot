import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/services/case_service.dart';

class _FakeCaseRepository implements CaseRepository {
  String? lastSimilarCasesCaseId;

  @override
  Future<List<CaseSummary>> getCases() async => [];

  @override
  Future<CaseDetail> getCaseDetail(String caseId) async =>
      throw UnimplementedError();

  @override
  Future<SimilarCases> getSimilarCases(String caseId) async {
    lastSimilarCasesCaseId = caseId;
    return const SimilarCases(
      cases: [],
      imagesUsed: 1,
      imagesTotal: 1,
      imagesHeldBack: 0,
    );
  }
}

class _FakeFindingsRepository implements FindingsRepository {
  @override
  Future<List<FindingItem>> getFindings(String caseId) async => [];
}

void main() {
  test('getSimilarCases passes the case id straight through', () async {
    final fakeCaseRepository = _FakeCaseRepository();
    final service = CaseService(fakeCaseRepository, _FakeFindingsRepository());

    await service.getSimilarCases('case-2');

    expect(fakeCaseRepository.lastSimilarCasesCaseId, 'case-2');
  });
}
