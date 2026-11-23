import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';

class ProcessingService {
  ProcessingService(
    this._repository, {
    this.pollInterval = const Duration(seconds: 2),
  });

  final ProcessingRepository _repository;

  /// How long to wait between two reads of a run that is still going.
  final Duration pollInterval;

  /// The run as the pipeline reports it, read again every [pollInterval]
  /// until it has ended. The pipeline has no way to push progress to the
  /// app, so following a run means asking.
  Stream<ProcessingRun> watchRun(String runId) async* {
    while (true) {
      final run = await _repository.getRun(runId);
      yield run;
      if (run.status.ended) return;
      await Future<void>.delayed(pollInterval);
    }
  }

  /// Each study's open failures, by case id. A study with none is absent.
  Future<Map<String, List<ProcessingFailure>>> failuresByCase() async {
    final studies = await _repository.getFailures();
    return {
      for (final study in studies)
        if (study.failures.isNotEmpty) study.caseId: study.failures,
    };
  }

  Future<void> retry(List<String> stepIds) => _repository.retry(stepIds);

  Future<void> discard(List<String> stepIds) => _repository.discard(stepIds);
}
