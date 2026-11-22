import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/processing_service.dart';
import 'package:radiologist_helper/services/providers.dart';

import '../support/fake_processing_repository.dart';

ProcessingRun _run(RunStatus status) =>
    ProcessingRun(status: status, openFailures: 0, steps: const []);

ProcessingFailure _failure(String stepId) => ProcessingFailure(
      stepId: stepId,
      stage: ProcessingStage.intake,
      itemName: 'img-$stepId',
      code: ProcessingErrorCode.unsupportedPixelData,
      attempts: 1,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14),
      canRetry: true,
    );

void main() {
  group('ProcessingService', () {
    test('watchRun reads the run until it has ended', () async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [
          _run(RunStatus.queued),
          _run(RunStatus.processing),
          _run(RunStatus.ready),
          _run(RunStatus.processing),
        ],
      });
      final service =
          ProcessingService(repository, pollInterval: Duration.zero);

      final statuses =
          await service.watchRun('run-1').map((r) => r.status).toList();

      expect(
          statuses, [RunStatus.queued, RunStatus.processing, RunStatus.ready]);
      expect(repository.runReads, 3);
    });

    test('watchRun reads a run that has already ended once', () async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.failed)],
      });

      final runs =
          await ProcessingService(repository).watchRun('run-1').toList();

      expect(runs.single.status, RunStatus.failed);
      expect(repository.runReads, 1);
    });

    test('watchRun ends with the error when a read fails', () async {
      final repository = FakeProcessingRepository(runError: Exception('down'));

      await expectLater(
        ProcessingService(repository).watchRun('run-1'),
        emitsError(isA<Exception>()),
      );
    });

    test('failuresByCase keys each study with failures by its case id',
        () async {
      final repository = FakeProcessingRepository(failures: [
        (caseId: 'case-1', failures: [_failure('s1'), _failure('s2')]),
        (caseId: 'case-2', failures: const []),
      ]);

      final byCase = await ProcessingService(repository).failuresByCase();

      expect(byCase.keys, ['case-1']);
      expect(byCase['case-1']!.map((f) => f.stepId), ['s1', 's2']);
    });

    test('retry and discard pass the step ids through', () async {
      final repository = FakeProcessingRepository();
      final service = ProcessingService(repository);

      await service.retry(['s1', 's2']);
      await service.discard(['s3']);

      expect(repository.retried, [
        ['s1', 's2'],
      ]);
      expect(repository.discarded, [
        ['s3'],
      ]);
    });
  });

  group('processing providers', () {
    test('open failures by case are empty while loading, then keyed by case',
        () async {
      final container = ProviderContainer(overrides: [
        processingRepositoryProvider.overrideWithValue(
          FakeProcessingRepository(failures: [
            (caseId: 'case-6', failures: [_failure('s1')]),
          ]),
        ),
      ]);
      addTearDown(container.dispose);

      expect(container.read(openFailuresByCaseProvider), isEmpty);

      await container.read(processingFailuresProvider.future);

      expect(container.read(openFailuresByCaseProvider).keys, ['case-6']);
    });

    test('the run provider follows the run to its end', () async {
      final container = ProviderContainer(overrides: [
        processingRepositoryProvider.overrideWithValue(
          FakeProcessingRepository(runs: {
            'run-1': [_run(RunStatus.ready)],
          }),
        ),
      ]);
      addTearDown(container.dispose);
      final subscription =
          container.listen(processingRunProvider('run-1'), (_, _) {});
      addTearDown(subscription.close);

      final run = await container.read(processingRunProvider('run-1').future);

      expect(run.status, RunStatus.ready);
    });
  });
}
