import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

import 'fixture_result.dart';

/// Mutable -- a test can reassign a result between calls (e.g. failure then
/// success, to drive a retry scenario) without re-overriding the provider.
class UploadRepositoryFixture implements UploadRepository {
  UploadRepositoryFixture({this.uploadStudyResult});

  FixtureResult<CaseDetail>? uploadStudyResult;

  @override
  Future<CaseDetail> uploadStudy(List<String> fileNames) =>
      uploadStudyResult?.resolve() ?? _unconfigured('uploadStudy');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'UploadRepositoryFixture.$method not configured for this test');
