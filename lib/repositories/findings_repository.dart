import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';

abstract class FindingsRepository {
  Future<List<FindingItem>> getFindings(String caseId);
}

class MockFindingsRepository implements FindingsRepository {
  @override
  Future<List<FindingItem>> getFindings(String caseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockFindingsFor(caseId);
  }
}
