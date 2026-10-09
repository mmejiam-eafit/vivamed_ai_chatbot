import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';

import 'fixture_result.dart';

/// Mutable -- a test can reassign a result between calls without
/// re-overriding the provider.
class FindingsRepositoryFixture implements FindingsRepository {
  FindingsRepositoryFixture({this.getFindingsResult});

  FixtureResult<List<FindingItem>>? getFindingsResult;

  @override
  Future<List<FindingItem>> getFindings(String caseId) =>
      getFindingsResult?.resolve() ?? _unconfigured('getFindings');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'FindingsRepositoryFixture.$method not configured for this test');
