import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/upload.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';
import 'package:radiologist_helper/services/upload_service.dart';

class _FakeUploadRepository implements UploadRepository {
  List<String>? lastFileNames;

  @override
  Future<UploadResult> uploadStudy(List<String> fileNames) async {
    lastFileNames = fileNames;
    return const UploadResult(caseId: 'case-fake', runId: 'run-fake');
  }
}

void main() {
  test('passes the file names straight through to the repository', () async {
    final fakeRepository = _FakeUploadRepository();
    final service = UploadService(fakeRepository);

    final result = await service.uploadStudy(['a.dcm', 'b.dcm']);

    expect(fakeRepository.lastFileNames, ['a.dcm', 'b.dcm']);
    expect(result.caseId, 'case-fake');
    expect(result.runId, 'run-fake');
  });
}
