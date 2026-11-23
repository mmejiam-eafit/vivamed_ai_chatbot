import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';

/// What a study's status is derived from, read the way the backend reads it
/// from the pipeline's tables. A run is active while a step of it is pending
/// or running; [started] means an active run has tried a step; [checked]
/// means an image got through its view check (done or held back).
typedef StudyFacts = ({
  int runs,
  int activeRuns,
  bool started,
  bool checked,
  int openFailures,
  String? activeRunId,
});

/// The backend's rule for a study's status, in its order of precedence (its
/// `derive_study_status`, data contract §9). The app itself never derives a
/// status; only the mocks stand in for the backend here.
StudyStatus deriveStudyStatus(
  StudyFacts facts, {
  required int pendingReviews,
  required int decidedReviews,
}) {
  if (facts.started) return StudyStatus.processing;
  if (facts.activeRuns > 0 || facts.runs == 0) return StudyStatus.queued;
  if (!facts.checked) return StudyStatus.failed;
  if (decidedReviews > 0) return StudyStatus.processing;
  if (pendingReviews > 0) return StudyStatus.needsReview;
  return StudyStatus.ready;
}

/// A stand-in for the pipeline: its runs and their steps, advanced one wave
/// at a time, and the studies uploaded through it. One instance is shared by
/// the mock upload, processing and case repositories, so an upload starts a
/// run the processing page can follow and the worklist can show. Each
/// `ProviderScope` gets its own, so an upload, a retry or a discard in one
/// test never leaks into the next.
///
/// Every mock study gets a finished backfill run, as the pipeline creates
/// every study together with a run.
///
/// An uploaded run is deterministic: the third file fails to be read
/// (unsupported pixel data), and the second file's labels fail on a model
/// that could not be loaded, after the pipeline's own automatic retries. A
/// retried step succeeds.
class MockPipeline {
  MockPipeline() {
    for (final study in mockCases) {
      _seedBackfill(study.id);
    }
    _seedCase6();
  }

  /// The run seeded for case-6, a finished upload with failures still open.
  static const case6RunId = '4c1e08a2-6b1d-4f3e-9a07-2d5c8e1f0b36';

  /// The id of the [n]th run [startRun] creates in a fresh pipeline: a UUID,
  /// as the pipeline writes one, so its first 8 hex characters start each
  /// of its items' internal names.
  static String uploadRunId(int n) =>
      '${(0x7f3a2100 + n).toRadixString(16)}-0000-4000-8000-'
      '${n.toRadixString(16).padLeft(12, '0')}';

  /// Each run's study, in the order the runs were created (a map literal
  /// keeps insertion order), so the latest of several runs is the last found.
  final _caseOfRun = <String, String>{};
  final _steps = <_Step>[];
  final _studies = <CaseSummary>[];
  var _lastRun = 0;
  var _lastBackfill = 0;
  var _lastStep = 0;

  static const _transient = {
    ProcessingErrorCode.modelUnavailable,
    ProcessingErrorCode.storageUnavailable,
    ProcessingErrorCode.outOfMemory,
  };

  /// What a transient failure costs in attempts before it stays failed.
  static const _automaticAttempts = 4;

  /// The studies uploaded through the pipeline, in upload order.
  List<CaseSummary> get studies => List.unmodifiable(_studies);

  /// Records a study an upload created. The pipeline creates a study
  /// together with its run, so [startRun] follows.
  void addStudy(CaseSummary study) => _studies.add(study);

  /// What [caseId]'s status is derived from (see [StudyFacts]).
  StudyFacts studyFacts(String caseId) {
    final runIds = [
      for (final entry in _caseOfRun.entries)
        if (entry.value == caseId) entry.key,
    ];
    final steps = _steps.where((s) => runIds.contains(s.runId)).toList();
    final activeRunIds = [
      for (final runId in runIds)
        if (steps.any((s) =>
            s.runId == runId &&
            (s.state == ProcessingStepState.pending ||
                s.state == ProcessingStepState.running)))
          runId,
    ];
    final startedRunIds = [
      for (final runId in activeRunIds)
        if (steps.any((s) => s.runId == runId && s.attempts > 0)) runId,
    ];
    return (
      runs: runIds.length,
      activeRuns: activeRunIds.length,
      started: startedRunIds.isNotEmpty,
      checked: steps.any((s) =>
          s.stage == ProcessingStage.viewCheck &&
          (s.state == ProcessingStepState.done ||
              s.state == ProcessingStepState.heldBack)),
      openFailures:
          steps.where((s) => s.state == ProcessingStepState.failed).length,
      // As the backend picks it: the latest run that has started, else the
      // latest, so a processing study points at a run in progress.
      activeRunId: startedRunIds.lastOrNull ?? activeRunIds.lastOrNull,
    );
  }

  /// Moves every run with waiting steps on one wave, as the workers would
  /// have done meanwhile.
  void advanceActive() {
    for (final runId in [..._caseOfRun.keys]) {
      advance(runId);
    }
  }

  /// Starts a run with one step per uploaded file and returns its id.
  String startRun(String caseId, int fileCount) {
    final runId = uploadRunId(++_lastRun);
    _caseOfRun[runId] = caseId;
    for (var position = 1; position <= fileCount; position++) {
      _steps.add(_Step(
        id: _nextStepId(),
        runId: runId,
        stage: ProcessingStage.intake,
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

  /// A finished backfill run for a study loaded before any upload: one image,
  /// read and through its view check.
  void _seedBackfill(String caseId) {
    final n = ++_lastBackfill;
    final runId = '${(0x0bf11000 + n).toRadixString(16).padLeft(8, '0')}'
        '-0000-4000-8000-${n.toRadixString(16).padLeft(12, '0')}';
    _caseOfRun[runId] = caseId;
    for (final stage in [ProcessingStage.intake, ProcessingStage.viewCheck]) {
      _steps.add(_Step(
        id: _nextStepId(),
        runId: runId,
        stage: stage,
        position: 1,
        state: ProcessingStepState.done,
        attempts: 1,
      ));
    }
  }

  /// A finished upload of four files to case-6, with three failures still
  /// open: one file in a format the pipeline cannot read, one whose header
  /// could not be read (nothing stored, so it can only be discarded), and one
  /// image's labels, whose model could not be loaded.
  void _seedCase6() {
    const runId = case6RunId;
    _caseOfRun[runId] = 'case-6';
    void add(
      ProcessingStage stage,
      int position,
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
          position: position,
          state: state,
          code: code,
          attempts: attempts,
          failedAt: failedAt,
          canRetry: canRetry,
        ));

    for (final position in [1, 2]) {
      add(ProcessingStage.intake, position, ProcessingStepState.done);
      add(ProcessingStage.viewCheck, position, ProcessingStepState.done);
      add(ProcessingStage.embedding, position, ProcessingStepState.done);
    }
    add(ProcessingStage.prediction, 1, ProcessingStepState.done);
    add(
      ProcessingStage.prediction,
      2,
      ProcessingStepState.failed,
      code: ProcessingErrorCode.modelUnavailable,
      attempts: _automaticAttempts,
      failedAt: DateTime.utc(2026, 11, 22, 10, 15, 40),
    );
    add(
      ProcessingStage.intake,
      3,
      ProcessingStepState.failed,
      code: ProcessingErrorCode.unsupportedPixelData,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14, 3),
    );
    // Failed inside the upload request, before any worker started it.
    add(
      ProcessingStage.intake,
      4,
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

  /// The file's position in its upload, carried to the image's steps.
  final int position;

  /// The pipeline's internal name for the file, derived from stored values
  /// as the pipeline derives it: the run id's first 8 hex characters and the
  /// file's 5-digit position, such as `7f3a2101-00003`. Fixed width up to
  /// 99,999 files; past that the position widens rather than being cut, so
  /// names stay unique. An image keeps the name of the file it came from.
  String get internalName =>
      '${runId.substring(0, 8)}-${position.toString().padLeft(5, '0')}';
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
        internalName: internalName,
        code: code!,
        attempts: attempts,
        failedAt: failedAt!,
        canRetry: canRetry,
      );
}
