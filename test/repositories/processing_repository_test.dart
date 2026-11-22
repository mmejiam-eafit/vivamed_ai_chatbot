import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';

List<ProcessingFailure> _failuresOf(MockPipeline pipeline, String caseId) =>
    pipeline.failures().firstWhere((f) => f.caseId == caseId).failures;

void main() {
  group('MockPipeline', () {
    test('case-6 starts ready with three open failures', () {
      final pipeline = MockPipeline();
      final run = pipeline.run('run-case-6');
      expect(run.status, RunStatus.ready);
      expect(run.openFailures, 3);

      final failures = _failuresOf(pipeline, 'case-6');
      expect(
        failures.map((f) => f.code),
        [
          ProcessingErrorCode.modelUnavailable,
          ProcessingErrorCode.unsupportedPixelData,
          ProcessingErrorCode.unreadableHeader,
        ],
      );
      expect(failures.map((f) => f.canRetry), [true, true, false]);
    });

    test(
        'an uploaded run goes queued, processing, then ready with its two '
        'failures', () {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-new', 3);
      expect(pipeline.run(runId).status, RunStatus.queued);
      expect(pipeline.run(runId).steps, hasLength(3));

      pipeline.advance(runId);
      final afterIntake = pipeline.run(runId);
      expect(afterIntake.status, RunStatus.processing);
      expect(afterIntake.openFailures, 1);

      pipeline
        ..advance(runId)
        ..advance(runId);
      final finished = pipeline.run(runId);
      expect(finished.status, RunStatus.ready);
      expect(finished.openFailures, 2);

      final failures = _failuresOf(pipeline, 'case-new');
      expect(failures.map((f) => (f.stage, f.code)), [
        (ProcessingStage.intake, ProcessingErrorCode.unsupportedPixelData),
        (ProcessingStage.prediction, ProcessingErrorCode.modelUnavailable),
      ]);
      // A transient failure is retried automatically before it stays failed.
      expect(failures.last.attempts, 4);
      expect(failures.first.attempts, 1);
    });

    test('an image keeps the name of the file it came from', () {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-new', 3);
      for (var i = 0; i < 3; i++) {
        pipeline.advance(runId);
      }
      final names = _failuresOf(pipeline, 'case-new').map((f) => f.itemName);
      expect(names.toSet(), hasLength(2));
      expect(names, everyElement(startsWith('img-')));
    });

    test('a retried step runs again and succeeds, reopening the run', () {
      final pipeline = MockPipeline();
      final labels = _failuresOf(pipeline, 'case-6').first;

      expect(pipeline.retry([labels.stepId]), isEmpty);
      expect(pipeline.run('run-case-6').status, RunStatus.processing);
      expect(_failuresOf(pipeline, 'case-6'), hasLength(2));

      pipeline.advance('run-case-6');
      final run = pipeline.run('run-case-6');
      expect(run.status, RunStatus.ready);
      expect(run.openFailures, 2);
    });

    test('a retried file goes on to its view check', () {
      final pipeline = MockPipeline();
      final file = _failuresOf(pipeline, 'case-6')[1];

      pipeline
        ..retry([file.stepId])
        ..advance('run-case-6');
      final viewChecks = pipeline
          .run('run-case-6')
          .steps
          .where((s) => s.stage == ProcessingStage.viewCheck);
      expect(
          viewChecks.where((s) => s.state == StepState.pending), hasLength(1));
    });

    test('retry refuses a step that cannot be retried, and resets none', () {
      final pipeline = MockPipeline();
      final failures = _failuresOf(pipeline, 'case-6');
      final unreadable = failures.last.stepId;

      final refused = pipeline.retry([failures.first.stepId, unreadable]);
      expect(refused, [unreadable]);
      expect(_failuresOf(pipeline, 'case-6'), hasLength(3));
    });

    test('retry refuses an unknown step', () {
      expect(MockPipeline().retry(['step-unknown']), ['step-unknown']);
    });

    test('discard drops a failed step, even one that cannot be retried', () {
      final pipeline = MockPipeline();
      final unreadable = _failuresOf(pipeline, 'case-6').last.stepId;

      expect(pipeline.discard([unreadable]), isEmpty);
      final run = pipeline.run('run-case-6');
      expect(run.openFailures, 2);
      expect(
        run.steps.where((s) => s.state == StepState.discarded),
        hasLength(1),
      );
    });

    test('discard refuses a step that is no longer failed', () {
      final pipeline = MockPipeline();
      final labels = _failuresOf(pipeline, 'case-6').first.stepId;
      pipeline.retry([labels]);

      expect(pipeline.discard([labels]), [labels]);
    });

    test('an unknown run is an error', () {
      expect(() => MockPipeline().run('run-unknown'), throwsArgumentError);
    });
  });

  group('MockProcessingRepository', () {
    test('getRun answers with the run, then moves it on', () async {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-new', 1);
      final repository = MockProcessingRepository(pipeline);

      expect((await repository.getRun(runId)).status, RunStatus.queued);
      expect((await repository.getRun(runId)).status, RunStatus.processing);
    });

    test('a refused retry throws StepConflictException naming the steps',
        () async {
      final pipeline = MockPipeline();
      final unreadable = _failuresOf(pipeline, 'case-6').last.stepId;

      await expectLater(
        MockProcessingRepository(pipeline).retry([unreadable]),
        throwsA(isA<StepConflictException>()
            .having((e) => e.stepIds, 'stepIds', [unreadable])),
      );
    });

    test('a refused discard throws StepConflictException', () async {
      await expectLater(
        MockProcessingRepository(MockPipeline()).discard(['step-unknown']),
        throwsA(isA<StepConflictException>()),
      );
    });

    test('each pipeline starts from the seed', () async {
      final first = MockPipeline();
      await MockProcessingRepository(first)
          .discard([_failuresOf(first, 'case-6').first.stepId]);

      final failures =
          await MockProcessingRepository(MockPipeline()).getFailures();
      expect(failures.single.failures, hasLength(3));
    });
  });
}
