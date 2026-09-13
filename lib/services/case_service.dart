import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';

class CaseService {
  CaseService(this._caseRepository, this._findingsRepository);

  final CaseRepository _caseRepository;
  final FindingsRepository _findingsRepository;

  Future<List<CaseSummary>> getCases() => _caseRepository.getCases();

  /// The actual transformation this layer exists for: combines the case
  /// endpoint and the findings endpoint into what a study review screen
  /// needs in one call.
  Future<({CaseDetail detail, List<FindingItem> findings})> getCaseDetail(
    String caseId,
  ) async {
    final detail = await _caseRepository.getCaseDetail(caseId);
    final findings = await _findingsRepository.getFindings(caseId);
    return (detail: detail, findings: findings);
  }

  Future<List<CaseSummary>> getSimilarCases(String caseId) =>
      _caseRepository.getSimilarCases(caseId);
}
