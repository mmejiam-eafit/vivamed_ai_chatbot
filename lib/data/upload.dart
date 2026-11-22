/// What the pipeline answers to an upload: the study the files went into,
/// and the run that now processes them. [runId] is null when every file was
/// already in the study, so there is nothing to process.
class UploadResult {
  const UploadResult({required this.caseId, this.runId});

  final String caseId;
  final String? runId;
}
