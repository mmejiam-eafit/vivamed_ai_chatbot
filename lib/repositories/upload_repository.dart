import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

abstract class UploadRepository {
  /// A study is a DICOM series -- usually many files, not one.
  Future<CaseDetail> uploadStudy(List<String> fileNames);
}

class MockUploadRepository implements UploadRepository {
  @override
  Future<CaseDetail> uploadStudy(List<String> fileNames) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = 'case-upload-${DateTime.now().millisecondsSinceEpoch}';
    final newCase = CaseSummary(
      id: id,
      title: 'Uploaded Study (${fileNames.length} images)',
      patient: 'New Patient',
      modality: 'Unknown',
      date: DateTime.now(),
      confidence: 0.0,
      severity: SeverityLevel.normal,
    );
    addMockCase(newCase);
    return CaseDetail(
      caseSummary: newCase,
      imageUrl: mockCaseImageUrlFor(id),
    );
  }
}
