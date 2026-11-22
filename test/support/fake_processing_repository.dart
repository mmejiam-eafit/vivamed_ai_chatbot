import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';

/// A [ProcessingRepository] with no delays and answers a test sets up.
class FakeProcessingRepository implements ProcessingRepository {
  FakeProcessingRepository({
    Map<String, List<ProcessingRun>>? runs,
    List<StudyFailures>? failures,
    this.runError,
    this.actionError,
  })  : runs = runs ?? {},
        failures = failures ?? [];

  /// What [getRun] answers for each run, one answer per call; the last
  /// answer repeats.
  final Map<String, List<ProcessingRun>> runs;

  /// The open failures. A successful retry or discard removes the steps it
  /// names, as the pipeline would.
  List<StudyFailures> failures;

  /// When set, [getRun] throws it.
  Object? runError;

  /// When set, [retry] and [discard] throw it and change nothing.
  Object? actionError;

  final retried = <List<String>>[];
  final discarded = <List<String>>[];
  var runReads = 0;

  @override
  Future<ProcessingRun> getRun(String runId) async {
    runReads++;
    if (runError != null) throw runError!;
    final answers = runs[runId]!;
    return answers.length > 1 ? answers.removeAt(0) : answers.single;
  }

  @override
  Future<List<StudyFailures>> getFailures() async => failures;

  @override
  Future<void> retry(List<String> stepIds) async {
    if (actionError != null) throw actionError!;
    retried.add(stepIds);
    _remove(stepIds);
  }

  @override
  Future<void> discard(List<String> stepIds) async {
    if (actionError != null) throw actionError!;
    discarded.add(stepIds);
    _remove(stepIds);
  }

  void _remove(List<String> stepIds) {
    failures = [
      for (final study in failures)
        (
          caseId: study.caseId,
          failures: [
            for (final f in study.failures)
              if (!stepIds.contains(f.stepId)) f,
          ],
        ),
    ];
  }
}
