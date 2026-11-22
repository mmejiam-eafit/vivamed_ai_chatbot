// What happens to a study after its upload: the pipeline's run, its steps,
// and the steps that failed. The pipeline reads each uploaded file, checks
// each image's view, then computes its labels and its similar-case search
// vectors, each as a step of its own that can fail while the rest of the
// study goes on.

/// A run's status, which the pipeline derives from its steps.
enum RunStatus {
  /// No step has started yet.
  queued('Queued'),

  /// Steps are under way.
  processing('Processing'),

  /// Every step has ended and at least one image passed its view check, so
  /// the study can be used, even with failures still open.
  ready('Ready'),

  /// Every step has ended and no image passed its view check.
  failed('Failed');

  const RunStatus(this.label);

  final String label;

  bool get ended => this == ready || this == failed;
}

/// Where one step stands.
enum StepState { pending, running, done, failed, skipped, heldBack, discarded }

/// What a step does, named the way a radiologist reads it.
enum ProcessingStage {
  /// Reads an uploaded file into an image.
  intake('Reading the file'),

  /// The view model and the blank-image rule.
  viewCheck('View check'),

  /// A classifier's labels for the image.
  prediction('Labels'),

  /// The vectors the similar-case search uses.
  embedding('Similar-case search');

  const ProcessingStage(this.label);

  final String label;
}

/// Why a step failed, with the message the app shows for it. The pipeline and
/// the app share this vocabulary.
enum ProcessingErrorCode {
  unreadableHeader(
    "The file's header could not be read. Upload the file again or check "
    'it at the source.',
  ),
  unsupportedPixelData(
    'The image is in a format the pipeline cannot read yet.',
  ),
  studyMismatch('This file belongs to another study.'),
  modelUnavailable('A model could not be loaded. Try again later.'),
  storageUnavailable('The image store could not be reached. Try again later.'),
  outOfMemory('The server ran out of memory. Try again later.'),
  internalError(
    'Something unexpected went wrong. Try again, or report it if it keeps '
    'failing.',
  );

  const ProcessingErrorCode(this.message);

  final String message;
}

class ProcessingStep {
  const ProcessingStep({required this.stage, required this.state});

  final ProcessingStage stage;
  final StepState state;
}

/// How far one stage of a run has got.
typedef StageProgress = ({
  ProcessingStage stage,
  int total,
  int done,
  int failed,
  int skipped,
  int heldBack,
  int discarded,
});

class ProcessingRun {
  const ProcessingRun({
    required this.status,
    required this.openFailures,
    required this.steps,
  });

  final RunStatus status;

  /// Steps of this run that failed and are not yet retried or discarded.
  final int openFailures;
  final List<ProcessingStep> steps;

  /// One entry per stage that has steps, in the order the stages run. A
  /// stage's steps only exist once the step before them has finished, so
  /// later stages appear as the run gets to them.
  List<StageProgress> get progress => [
        for (final stage in ProcessingStage.values)
          if (steps.any((s) => s.stage == stage)) _progressOf(stage),
      ];

  StageProgress _progressOf(ProcessingStage stage) {
    final states = [
      for (final s in steps)
        if (s.stage == stage) s.state,
    ];
    int count(StepState state) => states.where((s) => s == state).length;
    return (
      stage: stage,
      total: states.length,
      done: count(StepState.done),
      failed: count(StepState.failed),
      skipped: count(StepState.skipped),
      heldBack: count(StepState.heldBack),
      discarded: count(StepState.discarded),
    );
  }
}

/// A step that failed and waits for a radiologist to retry or discard it.
class ProcessingFailure {
  const ProcessingFailure({
    required this.stepId,
    required this.stage,
    required this.itemName,
    required this.code,
    required this.attempts,
    required this.failedAt,
    required this.canRetry,
  });

  final String stepId;
  final ProcessingStage stage;

  /// The name the pipeline gave the uploaded file when it read it, never the
  /// file's original name. An image keeps the name of the file it came from.
  final String itemName;
  final ProcessingErrorCode code;

  /// How many times a worker has started the step, automatic retries
  /// included.
  final int attempts;
  final DateTime failedAt;

  /// False only when nothing was stored to retry from, so the file has to be
  /// uploaded again.
  final bool canRetry;
}

/// One study's open failures, as the pipeline groups them.
typedef StudyFailures = ({String caseId, List<ProcessingFailure> failures});
