import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';
import 'package:radiologist_helper/services/upload_service.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

class _FakeUploadRepository implements UploadRepository {
  List<String>? lastFileNames;

  @override
  Future<CaseDetail> uploadStudy(List<String> fileNames) async {
    lastFileNames = fileNames;
    return CaseDetail(
      caseSummary: CaseSummary(
        id: 'case-fake',
        title: 'Fake',
        patient: 'Fake Patient',
        modality: 'Unknown',
        date: DateTime(2026, 1, 1),
        confidence: 0,
        severity: SeverityLevel.normal,
      ),
      imageUrl: 'https://example.com/fake.png',
    );
  }
}

void main() {
  test('passes the file names straight through to the repository', () async {
    final fakeRepository = _FakeUploadRepository();
    final service = UploadService(fakeRepository);

    final detail = await service.uploadStudy(['a.dcm', 'b.dcm']);

    expect(fakeRepository.lastFileNames, ['a.dcm', 'b.dcm']);
    expect(detail.caseSummary.id, 'case-fake');
  });
}
