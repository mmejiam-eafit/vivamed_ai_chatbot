import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';

/// The pipeline refused a retry or discard because some of the named steps
/// were no longer failed, or could not be retried. Nothing was changed.
class StepConflictException implements Exception {
  const StepConflictException(this.stepIds);

  /// The steps that caused the refusal.
  final List<String> stepIds;

  @override
  String toString() => 'StepConflictException: ${stepIds.join(', ')}';
}

/// The pipeline's run and failure endpoints.
abstract class ProcessingRepository {
  /// One run's status and steps: the progress of an upload.
  Future<ProcessingRun> getRun(String runId);

  /// Every open failure the user may see, grouped by study.
  Future<List<StudyFailures>> getFailures();

  /// Sends failed steps back to be run again, from what is already stored.
  /// Throws [StepConflictException] when any step is not failed or cannot be
  /// retried, and then resets none.
  Future<void> retry(List<String> stepIds);

  /// Drops failed steps for good. Throws [StepConflictException] when any
  /// step is not failed, and then discards none.
  Future<void> discard(List<String> stepIds);
}

class MockProcessingRepository implements ProcessingRepository {
  MockProcessingRepository(this._pipeline);

  final MockPipeline _pipeline;

  static const _latency = Duration(milliseconds: 300);

  /// Answers with the run as it stands, then moves it a moment on: its
  /// waiting steps end, as a worker would have ended them before the next
  /// read. So a new upload reads as queued first.
  @override
  Future<ProcessingRun> getRun(String runId) async {
    await Future<void>.delayed(_latency);
    final run = _pipeline.run(runId);
    _pipeline.advance(runId);
    return run;
  }

  @override
  Future<List<StudyFailures>> getFailures() async {
    await Future<void>.delayed(_latency);
    return _pipeline.failures();
  }

  @override
  Future<void> retry(List<String> stepIds) async {
    await Future<void>.delayed(_latency);
    final refused = _pipeline.retry(stepIds);
    if (refused.isNotEmpty) throw StepConflictException(refused);
  }

  @override
  Future<void> discard(List<String> stepIds) async {
    await Future<void>.delayed(_latency);
    final refused = _pipeline.discard(stepIds);
    if (refused.isNotEmpty) throw StepConflictException(refused);
  }
}
