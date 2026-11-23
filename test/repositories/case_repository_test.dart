import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

MockCaseRepository _repository([MockPipeline? pipeline]) =>
    MockCaseRepository(pipeline ?? MockPipeline(), MockImageReviewRepository());

void main() {
  group('MockCaseRepository.getCases', () {
    test('lists every seeded study with the status the backend derives',
        () async {
      final cases = await _repository().getCases();
      final byId = {for (final c in cases) c.id: c};

      expect(cases, hasLength(mockCases.length));
      for (final id in ['case-1', 'case-2', 'case-3', 'case-4', 'case-5']) {
        expect(byId[id]!.status, StudyStatus.ready, reason: id);
        expect(byId[id]!.openFailures, 0, reason: id);
      }
      // A decision is being applied, and its upload left three failures.
      expect(byId['case-6']!.status, StudyStatus.processing);
      expect(byId['case-6']!.openFailures, 3);
      expect(byId['case-6']!.activeRunId, isNull);
      expect(byId['case-7']!.status, StudyStatus.needsReview);
      expect(byId['case-8']!.status, StudyStatus.needsReview);
    });

    test('an upload reads queued, then processing, then ready with its '
        'failures', () async {
      final pipeline = MockPipeline();
      final upload = await MockUploadRepository(pipeline)
          .uploadStudy(['1.dcm', '2.dcm', '3.dcm']);
      final repository = _repository(pipeline);

      Future<CaseSummary> read() async => (await repository.getCases())
          .singleWhere((c) => c.id == upload.caseId);

      final queued = await read();
      expect(queued.status, StudyStatus.queued);
      expect(queued.activeRunId, upload.runId);

      final processing = await read();
      expect(processing.status, StudyStatus.processing);
      expect(processing.activeRunId, upload.runId);

      CaseSummary study;
      do {
        study = await read();
      } while (study.status.inProgress);
      expect(study.status, StudyStatus.ready);
      expect(study.openFailures, 2);
      expect(study.activeRunId, isNull);
    });

    test('a study uploaded in one pipeline is not listed by another',
        () async {
      final pipeline = MockPipeline();
      await MockUploadRepository(pipeline).uploadStudy(['1.dcm']);

      expect(await _repository(pipeline).getCases(),
          hasLength(mockCases.length + 1));
      expect(await _repository().getCases(), hasLength(mockCases.length));
    });
  });

  group('MockCaseRepository.getCaseDetail', () {
    test('carries the same status as the list', () async {
      final detail = await _repository().getCaseDetail('case-6');
      expect(detail.caseSummary.status, StudyStatus.processing);
      expect(detail.caseSummary.openFailures, 3);
    });

    test('finds a study uploaded through the pipeline', () async {
      final pipeline = MockPipeline();
      final upload =
          await MockUploadRepository(pipeline).uploadStudy(['1.dcm']);
      final detail = await _repository(pipeline).getCaseDetail(upload.caseId);
      expect(detail.caseSummary.status, StudyStatus.queued);
    });
  });

  group('MockCaseRepository.getSimilarCases', () {
    test('excludes the given case', () async {
      final similar = await _repository().getSimilarCases('case-1');
      expect(similar.cases.any((c) => c.id == 'case-1'), isFalse);
    });

    test('returns up to 3 other cases', () async {
      final similar = await _repository().getSimilarCases('case-1');
      expect(similar.cases.length, 3);
      expect(similar.cases.length, lessThanOrEqualTo(mockCases.length - 1));
    });

    test('carries the status of each similar study', () async {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-2', 1);
      final similar = await _repository(pipeline).getSimilarCases('case-1');
      final byId = {for (final c in similar.cases) c.id: c};
      expect(byId['case-2']!.status, StudyStatus.queued);
      expect(byId['case-2']!.activeRunId, runId);
      expect(byId['case-3']!.status, StudyStatus.ready);
    });

    test('a study with nothing held back is searched with its one image',
        () async {
      final similar = await _repository().getSimilarCases('case-1');
      expect(similar.imagesUsed, 1);
      expect(similar.imagesTotal, 1);
      expect(similar.imagesHeldBack, 0);
    });

    test('a study with an image held back is searched with the others',
        () async {
      final similar = await _repository().getSimilarCases('case-7');
      expect(similar.imagesUsed, 2);
      expect(similar.imagesTotal, 3);
      expect(similar.imagesHeldBack, 1);
      expect(similar.cases, isNotEmpty);
    });

    test('a study held back entirely has no similar cases', () async {
      final similar = await _repository().getSimilarCases('case-6');
      expect(similar.imagesUsed, 0);
      expect(similar.imagesHeldBack, 1);
      expect(similar.cases, isEmpty);
    });
  });
}
