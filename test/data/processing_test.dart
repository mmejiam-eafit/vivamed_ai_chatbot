import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';

ProcessingStep _step(ProcessingStage stage, StepState state) =>
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
          _step(ProcessingStage.viewCheck, StepState.pending),
          _step(ProcessingStage.intake, StepState.done),
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
          _step(ProcessingStage.intake, StepState.done),
          _step(ProcessingStage.intake, StepState.done),
          _step(ProcessingStage.intake, StepState.failed),
          _step(ProcessingStage.intake, StepState.skipped),
          _step(ProcessingStage.intake, StepState.discarded),
          _step(ProcessingStage.viewCheck, StepState.heldBack),
          _step(ProcessingStage.viewCheck, StepState.running),
        ],
      );
      final intake = run.progress.first;
      expect(intake.total, 5);
      expect(intake.done, 2);
      expect(intake.failed, 1);
      expect(intake.skipped, 1);
      expect(intake.discarded, 1);
      expect(intake.heldBack, 0);

      final viewCheck = run.progress.last;
      expect(viewCheck.total, 2);
      expect(viewCheck.done, 0);
      expect(viewCheck.heldBack, 1);
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
