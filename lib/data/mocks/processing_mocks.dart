import 'package:radiologist_helper/data/processing.dart';

/// A stand-in for the pipeline: its runs and their steps, advanced one wave
/// at a time. One instance is shared by the mock upload and processing
/// repositories, so an upload starts a run the processing page can follow.
/// Each `ProviderScope` gets its own, so a retry or discard in one test never
/// leaks into the next.
///
/// An uploaded run is deterministic: the third file fails to be read
/// (unsupported pixel data), and the second file's labels fail on a model
/// that could not be loaded, after the pipeline's own automatic retries. A
/// retried step succeeds.
class MockPipeline {
  MockPipeline() {
    _seedCase6();
  }

  final _caseOfRun = <String, String>{};
  final _steps = <_Step>[];
  var _lastRun = 0;
  var _lastStep = 0;
  var _lastName = 0x7f3a20;

  static const _transient = {
    ProcessingErrorCode.modelUnavailable,
    ProcessingErrorCode.storageUnavailable,
    ProcessingErrorCode.outOfMemory,
  };

  /// What a transient failure costs in attempts before it stays failed.
  static const _automaticAttempts = 4;

  /// Starts a run with one step per uploaded file and returns its id.
  String startRun(String caseId, int fileCount) {
    final runId = 'run-${++_lastRun}';
    _caseOfRun[runId] = caseId;
    for (var position = 1; position <= fileCount; position++) {
      _steps.add(_Step(
        id: _nextStepId(),
        runId: runId,
        stage: ProcessingStage.intake,
        itemName: 'img-${(++_lastName).toRadixString(16)}',
        position: position,
        failWith:
            position == 3 ? ProcessingErrorCode.unsupportedPixelData : null,
      ));
    }
    return runId;
  }

  /// Ends every step of [runId] that is waiting, as a worker would, and
  /// creates the steps that follow the ones that succeeded.
  void advance(String runId) {
    final waiting = _steps
        .where(
            (s) => s.runId == runId && s.state == ProcessingStepState.pending)
        .toList();
    for (final step in waiting) {
      _finish(step);
    }
  }

  ProcessingRun run(String runId) {
    if (!_caseOfRun.containsKey(runId)) {
      throw ArgumentError.value(runId, 'runId');
    }
    final steps = _steps.where((s) => s.runId == runId).toList();
    return ProcessingRun(
      status: _statusOf(steps),
      openFailures:
          steps.where((s) => s.state == ProcessingStepState.failed).length,
      steps: [
        for (final s in steps) ProcessingStep(stage: s.stage, state: s.state),
      ],
    );
  }

  List<StudyFailures> failures() {
    final byCase = <String, List<ProcessingFailure>>{};
    for (final step
        in _steps.where((s) => s.state == ProcessingStepState.failed)) {
      byCase
          .putIfAbsent(_caseOfRun[step.runId]!, () => [])
          .add(step.toFailure());
    }
    return [
      for (final entry in byCase.entries)
        (caseId: entry.key, failures: entry.value),
    ];
  }

  /// Sends failed steps back to waiting. Returns the ids it refused (not
  /// failed, unknown, or with nothing stored to retry from), and then changes
  /// nothing.
  List<String> retry(List<String> stepIds) {
    final refused = [
      for (final id in stepIds)
        if (_failedStep(id)?.canRetry != true) id,
    ];
    if (refused.isNotEmpty) return refused;
    for (final id in stepIds) {
      _failedStep(id)!.state = ProcessingStepState.pending;
    }
    return const [];
  }

  /// Marks failed steps discarded. Returns the ids it refused (not failed, or
  /// unknown), and then changes nothing.
  List<String> discard(List<String> stepIds) {
    final refused = [
      for (final id in stepIds)
        if (_failedStep(id) == null) id,
    ];
    if (refused.isNotEmpty) return refused;
    for (final id in stepIds) {
      _failedStep(id)!.state = ProcessingStepState.discarded;
    }
    return const [];
  }

  _Step? _failedStep(String id) {
    for (final step in _steps) {
      if (step.id == id && step.state == ProcessingStepState.failed) {
        return step;
      }
    }
    return null;
  }

  String _nextStepId() => 'step-${++_lastStep}';

  void _finish(_Step step) {
    final failure = step.failWith;
    if (failure != null) {
      step
        ..failWith = null
        ..state = ProcessingStepState.failed
        ..code = failure
        ..attempts += _transient.contains(failure) ? _automaticAttempts : 1
        ..failedAt = DateTime.now().toUtc();
      return;
    }
    step
      ..state = ProcessingStepState.done
      ..attempts += 1;
    for (final stage in _next(step.stage)) {
      _steps.add(_Step(
        id: _nextStepId(),
        runId: step.runId,
        stage: stage,
        itemName: step.itemName,
        position: step.position,
        failWith: stage == ProcessingStage.prediction && step.position == 2
            ? ProcessingErrorCode.modelUnavailable
            : null,
      ));
    }
  }

  static List<ProcessingStage> _next(ProcessingStage stage) => switch (stage) {
        ProcessingStage.intake => const [ProcessingStage.viewCheck],
        // Every mock image is frontal, so each gets its search vectors.
        ProcessingStage.viewCheck => const [
            ProcessingStage.prediction,
            ProcessingStage.embedding,
          ],
        ProcessingStage.prediction || ProcessingStage.embedding => const [],
      };

  static RunStatus _statusOf(List<_Step> steps) {
    if (steps.every(
        (s) => s.state == ProcessingStepState.pending && s.attempts == 0)) {
      return RunStatus.queued;
    }
    if (steps.any((s) =>
        s.state == ProcessingStepState.pending ||
        s.state == ProcessingStepState.running)) {
      return RunStatus.processing;
    }
    final anyChecked = steps.any(
      (s) =>
          s.stage == ProcessingStage.viewCheck &&
          s.state == ProcessingStepState.done,
    );
    return anyChecked ? RunStatus.ready : RunStatus.failed;
  }

  /// A finished upload of four files to case-6, with three failures still
  /// open: one file in a format the pipeline cannot read, one whose header
  /// could not be read (nothing stored, so it can only be discarded), and one
  /// image's labels, whose model could not be loaded.
  void _seedCase6() {
    const runId = 'run-case-6';
    _caseOfRun[runId] = 'case-6';
    void add(
      ProcessingStage stage,
      String itemName,
      ProcessingStepState state, {
      ProcessingErrorCode? code,
      int attempts = 1,
      DateTime? failedAt,
      bool canRetry = true,
    }) =>
        _steps.add(_Step(
          id: _nextStepId(),
          runId: runId,
          stage: stage,
          itemName: itemName,
          position: 0,
          state: state,
          code: code,
          attempts: attempts,
          failedAt: failedAt,
          canRetry: canRetry,
        ));

    for (final name in ['img-4c1e07', 'img-4c1e08']) {
      add(ProcessingStage.intake, name, ProcessingStepState.done);
      add(ProcessingStage.viewCheck, name, ProcessingStepState.done);
      add(ProcessingStage.embedding, name, ProcessingStepState.done);
    }
    add(ProcessingStage.prediction, 'img-4c1e07', ProcessingStepState.done);
    add(
      ProcessingStage.prediction,
      'img-4c1e08',
      ProcessingStepState.failed,
      code: ProcessingErrorCode.modelUnavailable,
      attempts: _automaticAttempts,
      failedAt: DateTime.utc(2026, 11, 22, 10, 15, 40),
    );
    add(
      ProcessingStage.intake,
      'img-4c1e09',
      ProcessingStepState.failed,
      code: ProcessingErrorCode.unsupportedPixelData,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14, 3),
    );
    // Failed inside the upload request, before any worker started it.
    add(
      ProcessingStage.intake,
      'img-4c1e0a',
      ProcessingStepState.failed,
      code: ProcessingErrorCode.unreadableHeader,
      attempts: 0,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14, 1),
      canRetry: false,
    );
  }
}

class _Step {
  _Step({
    required this.id,
    required this.runId,
    required this.stage,
    required this.itemName,
    required this.position,
    this.state = ProcessingStepState.pending,
    this.code,
    this.failWith,
    this.attempts = 0,
    this.failedAt,
    this.canRetry = true,
  });

  final String id;
  final String runId;
  final ProcessingStage stage;
  final String itemName;

  /// The file's position in its upload, carried to the image's steps; 0 for
  /// seeded steps, which no rule reads.
  final int position;
  ProcessingStepState state;
  ProcessingErrorCode? code;

  /// The failure this step's next attempt ends in; null to succeed.
  ProcessingErrorCode? failWith;
  int attempts;
  DateTime? failedAt;
  final bool canRetry;

  ProcessingFailure toFailure() => ProcessingFailure(
        stepId: id,
        stage: stage,
        itemName: itemName,
        code: code!,
        attempts: attempts,
        failedAt: failedAt!,
        canRetry: canRetry,
      );
}
