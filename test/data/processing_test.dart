import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';

ProcessingStep _step(ProcessingStage stage, ProcessingStepState state) =>
    ProcessingStep(stage: stage, state: state);

void main() {
  group('RunStatus', () {
    test('only ready and failed have ended', () {
      expect(RunStatus.queued.ended, isFalse);
      expect(RunStatus.processing.ended, isFalse);
      expect(RunStatus.ready.ended, isTrue);
      expect(RunStatus.failed.ended, isTrue);
    });

    test('every status has a label', () {
      expect(
        RunStatus.values.map((s) => s.label),
        ['Queued', 'Processing', 'Ready', 'Failed'],
      );
    });
  });

  test('stages are named the way a radiologist reads them', () {
    expect(
      ProcessingStage.values.map((s) => s.label),
      ['Reading the file', 'View check', 'Labels', 'Similar-case search'],
    );
  });

  test('every skip code reads after a count', () {
    expect(
      ProcessingSkipCode.values.map((c) => c.label),
      ['not DICOM', 'no image', 'already in the study', 'not chest'],
    );
  });

  test('every error code has a message', () {
    for (final code in ProcessingErrorCode.values) {
      expect(code.message, isNotEmpty, reason: code.name);
    }
  });

  group('ProcessingRun.progress', () {
    test('has one entry per stage with steps, in the order stages run', () {
      final run = ProcessingRun(
        status: RunStatus.processing,
        openFailures: 0,
        steps: [
          _step(ProcessingStage.viewCheck, ProcessingStepState.pending),
          _step(ProcessingStage.intake, ProcessingStepState.done),
        ],
      );
      expect(
        run.progress.map((p) => p.stage),
        [ProcessingStage.intake, ProcessingStage.viewCheck],
      );
    });

    test('counts each stage by state', () {
      final run = ProcessingRun(
        status: RunStatus.ready,
        openFailures: 1,
        steps: [
          _step(ProcessingStage.intake, ProcessingStepState.done),
          _step(ProcessingStage.intake, ProcessingStepState.done),
          _step(ProcessingStage.intake, ProcessingStepState.failed),
          _step(ProcessingStage.intake, ProcessingStepState.skipped),
          _step(ProcessingStage.intake, ProcessingStepState.discarded),
          _step(ProcessingStage.viewCheck, ProcessingStepState.heldBack),
          _step(ProcessingStage.viewCheck, ProcessingStepState.running),
        ],
      );
      final intake = run.progress.first;
      expect(intake.total, 5);
      expect(intake.done, 2);
      expect(intake.failed, 1);
      expect(intake.skipped, {null: 1});
      expect(intake.discarded, 1);
      expect(intake.heldBack, 0);

      final viewCheck = run.progress.last;
      expect(viewCheck.total, 2);
      expect(viewCheck.done, 0);
      expect(viewCheck.heldBack, 1);
    });

    test('counts skips by why, in code order, unknown ones last', () {
      final run = ProcessingRun(
        status: RunStatus.ready,
        openFailures: 0,
        steps: [
          for (final code in [
            ProcessingSkipCode.notChest,
            null,
            ProcessingSkipCode.notChest,
            ProcessingSkipCode.notDicom,
          ])
            ProcessingStep(
              stage: ProcessingStage.intake,
              state: ProcessingStepState.skipped,
              skipCode: code,
            ),
          _step(ProcessingStage.intake, ProcessingStepState.done),
        ],
      );
      final skipped = run.progress.single.skipped;
      expect(skipped, {
        ProcessingSkipCode.notDicom: 1,
        ProcessingSkipCode.notChest: 2,
        null: 1,
      });
      expect(skipped.keys, [
        ProcessingSkipCode.notDicom,
        ProcessingSkipCode.notChest,
        null,
      ]);
    });

    test('is empty for a run with no steps', () {
      const run = ProcessingRun(
        status: RunStatus.queued,
        openFailures: 0,
        steps: [],
      );
      expect(run.progress, isEmpty);
    });
  });
}
