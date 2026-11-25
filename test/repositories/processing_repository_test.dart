import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';

List<ProcessingFailure> _failuresOf(MockPipeline pipeline, String caseId) =>
    pipeline.failures().firstWhere((f) => f.caseId == caseId).failures;

void main() {
  group('MockPipeline', () {
    test('case-6 starts ready with three open failures', () {
      final pipeline = MockPipeline();
      final run = pipeline.run(MockPipeline.case6RunId);
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

    test(
        'a fourth file is skipped at upload as not chest, and the run stays '
        'queued until a step runs', () {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-new', 4);
      final queued = pipeline.run(runId);
      expect(queued.status, RunStatus.queued);
      expect(queued.steps.map((s) => (s.state, s.skipCode)), [
        (ProcessingStepState.pending, null),
        (ProcessingStepState.pending, null),
        (ProcessingStepState.pending, null),
        (ProcessingStepState.skipped, ProcessingSkipCode.notChest),
      ]);

      pipeline
        ..advance(runId)
        ..advance(runId)
        ..advance(runId);
      final intake = pipeline.run(runId).progress.first;
      expect(intake.total, 4);
      expect(intake.done, 2);
      expect(intake.failed, 1);
      expect(intake.skipped, {ProcessingSkipCode.notChest: 1});
    });

    test('an image keeps the name of the file it came from', () {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-new', 3);
      for (var i = 0; i < 3; i++) {
        pipeline.advance(runId);
      }
      final names = _failuresOf(pipeline, 'case-new').map((f) => f.internalName);
      // The second file's labels and the third file's reading failed: each
      // named by the run id's first 8 hex characters and its position.
      final prefix = runId.substring(0, 8);
      expect(names, unorderedEquals(['$prefix-00002', '$prefix-00003']));
    });

    test('a retried step runs again and succeeds, reopening the run', () {
      final pipeline = MockPipeline();
      final labels = _failuresOf(pipeline, 'case-6').first;

      expect(pipeline.retry([labels.stepId]), isEmpty);
      expect(pipeline.run(MockPipeline.case6RunId).status, RunStatus.processing);
      expect(_failuresOf(pipeline, 'case-6'), hasLength(2));

      pipeline.advance(MockPipeline.case6RunId);
      final run = pipeline.run(MockPipeline.case6RunId);
      expect(run.status, RunStatus.ready);
      expect(run.openFailures, 2);
    });

    test('a retried file goes on to its view check', () {
      final pipeline = MockPipeline();
      final file = _failuresOf(pipeline, 'case-6')[1];

      pipeline
        ..retry([file.stepId])
        ..advance(MockPipeline.case6RunId);
      final viewChecks = pipeline
          .run(MockPipeline.case6RunId)
          .steps
          .where((s) => s.stage == ProcessingStage.viewCheck);
      expect(viewChecks.where((s) => s.state == ProcessingStepState.pending),
          hasLength(1));
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
      final run = pipeline.run(MockPipeline.case6RunId);
      expect(run.openFailures, 2);
      expect(
        run.steps.where((s) => s.state == ProcessingStepState.discarded),
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

  group('MockPipeline.studyFacts', () {
    test('a seeded study has a finished run through its view check', () {
      final facts = MockPipeline().studyFacts('case-1');
      expect(facts.runs, 1);
      expect(facts.activeRuns, 0);
      expect(facts.checked, isTrue);
      expect(facts.openFailures, 0);
      expect(facts.activeRunId, isNull);
    });

    test('case-6 counts its open failures across its runs', () {
      final facts = MockPipeline().studyFacts('case-6');
      expect(facts.runs, 2);
      expect(facts.openFailures, 3);
      expect(facts.activeRunId, isNull);
    });

    test('a new run is active, and started once a worker tries a step', () {
      final pipeline = MockPipeline();
      final runId = pipeline.startRun('case-1', 2);
      final before = pipeline.studyFacts('case-1');
      expect(before.activeRuns, 1);
      expect(before.started, isFalse);
      expect(before.activeRunId, runId);

      pipeline.advanceActive();
      expect(pipeline.studyFacts('case-1').started, isTrue);
    });

    test('with two active runs, neither started, the one to follow is the '
        'latest created', () {
      final pipeline = MockPipeline()..startRun('case-1', 1);
      final latest = pipeline.startRun('case-1', 1);
      expect(pipeline.studyFacts('case-1').activeRunId, latest);
    });

    test('a run that has started comes before a newer one still queued', () {
      final pipeline = MockPipeline();
      final older = pipeline.startRun('case-1', 2);
      pipeline.advance(older);
      pipeline.startRun('case-1', 1);

      final facts = pipeline.studyFacts('case-1');
      expect(facts.started, isTrue);
      expect(facts.activeRunId, older);
    });

    test('a study the pipeline never ran has no runs', () {
      expect(MockPipeline().studyFacts('case-unknown').runs, 0);
    });
  });

  group('deriveStudyStatus', () {
    StudyFacts facts({
      int runs = 1,
      int activeRuns = 0,
      bool started = false,
      bool checked = true,
      int openFailures = 0,
    }) =>
        (
          runs: runs,
          activeRuns: activeRuns,
          started: started,
          checked: checked,
          openFailures: openFailures,
          activeRunId: activeRuns > 0 ? 'run' : null,
        );

    StudyStatus derive(StudyFacts facts, {int pending = 0, int decided = 0}) =>
        deriveStudyStatus(
          facts,
          pendingReviews: pending,
          decidedReviews: decided,
        );

    test('an active run that has started reads processing, over the rest', () {
      expect(
        derive(
          facts(activeRuns: 1, started: true, checked: false),
          pending: 1,
          decided: 1,
        ),
        StudyStatus.processing,
      );
    });

    test('an active run no worker has started reads queued', () {
      expect(derive(facts(activeRuns: 1), pending: 1), StudyStatus.queued);
    });

    test('a study with no runs reads queued', () {
      expect(derive(facts(runs: 0, checked: false)), StudyStatus.queued);
    });

    test('no image through its view check reads failed, even with its '
        'failures discarded', () {
      expect(derive(facts(checked: false)), StudyStatus.failed);
    });

    test('a decision being applied reads processing, over a pending review',
        () {
      expect(derive(facts(), pending: 1, decided: 1), StudyStatus.processing);
    });

    test('a pending review reads needs review', () {
      expect(derive(facts(), pending: 1), StudyStatus.needsReview);
    });

    test('anything else reads ready, open failures or not', () {
      expect(derive(facts(openFailures: 2)), StudyStatus.ready);
    });
  });
}
