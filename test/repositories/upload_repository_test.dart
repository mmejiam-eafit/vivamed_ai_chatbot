import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

void main() {
  group('MockUploadRepository', () {
    test('creates a study titled with the number of files', () async {
      final pipeline = MockPipeline();
      final result = await MockUploadRepository(pipeline)
          .uploadStudy(['1.dcm', '2.dcm', '3.dcm']);

      final created = pipeline.studies.single;
      expect(created.id, result.caseId);
      expect(created.title, contains('3'));
    });

    test('records the study in its own pipeline, never the shared mocks',
        () async {
      final before = mockCases.length;

      await MockUploadRepository(MockPipeline()).uploadStudy(['1.dcm']);

      expect(mockCases, hasLength(before));
      expect(MockPipeline().studies, isEmpty);
    });

    test('starts a queued run with one step per file', () async {
      final pipeline = MockPipeline();
      final result = await MockUploadRepository(pipeline)
          .uploadStudy(['1.dcm', '2.dcm', '3.dcm']);

      final run = pipeline.run(result.runId!);
      expect(run.status, RunStatus.queued);
      expect(run.steps, hasLength(3));
      expect(
        run.steps.map((s) => s.stage),
        everyElement(ProcessingStage.intake),
      );
    });

    test('each upload gets a distinct case and run', () async {
      final repository = MockUploadRepository(MockPipeline());
      final first = await repository.uploadStudy(['1.dcm']);
      // The case id is time-based; make sure the clock has moved.
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final second = await repository.uploadStudy(['2.dcm']);

      expect(first.caseId, isNot(second.caseId));
      expect(first.runId, isNot(second.runId));
    });
  });
}
