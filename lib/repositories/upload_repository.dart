import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/upload.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

abstract class UploadRepository {
  /// A study is a DICOM series -- usually many files, not one. The answer
  /// comes once the files are stored; reading them and running the models
  /// happen afterwards, in the run it names.
  Future<UploadResult> uploadStudy(List<String> fileNames);
}

class MockUploadRepository implements UploadRepository {
  MockUploadRepository(this._pipeline);

  final MockPipeline _pipeline;

  @override
  Future<UploadResult> uploadStudy(List<String> fileNames) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = 'case-upload-${DateTime.now().millisecondsSinceEpoch}';
    _pipeline.addStudy(CaseSummary(
      id: id,
      title: 'Uploaded Study (${fileNames.length} images)',
      patient: 'New Patient',
      modality: 'Unknown',
      date: DateTime.now(),
      confidence: 0.0,
      severity: SeverityLevel.normal,
    ));
    return UploadResult(
      caseId: id,
      runId: _pipeline.startRun(id, fileNames.length),
    );
  }
}
