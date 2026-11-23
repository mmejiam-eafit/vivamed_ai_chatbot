import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';

import 'fixture_result.dart';

/// Each method's result is configured independently, as in
/// [ImageReviewRepositoryFixture]; an unconfigured one throws loudly.
/// Mutable -- a test can reassign `getFailuresResult` before a retry or
/// discard, so the refetch that follows it returns the list without the step.
class ProcessingRepositoryFixture implements ProcessingRepository {
  ProcessingRepositoryFixture({
    this.getRunResult,
    this.getFailuresResult,
    this.retryResult,
    this.discardResult,
  });

  FixtureResult<ProcessingRun>? getRunResult;
  FixtureResult<List<StudyFailures>>? getFailuresResult;
  FixtureResult<void>? retryResult;
  FixtureResult<void>? discardResult;

  @override
  Future<ProcessingRun> getRun(String runId) =>
      getRunResult?.resolve() ?? _unconfigured('getRun');

  @override
  Future<List<StudyFailures>> getFailures() =>
      getFailuresResult?.resolve() ?? _unconfigured('getFailures');

  @override
  Future<void> retry(List<String> stepIds) =>
      retryResult?.resolve() ?? _unconfigured('retry');

  @override
  Future<void> discard(List<String> stepIds) =>
      discardResult?.resolve() ?? _unconfigured('discard');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'ProcessingRepositoryFixture.$method not configured for this test');
