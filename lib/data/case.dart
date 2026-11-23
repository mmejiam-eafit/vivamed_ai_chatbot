import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

/// Where a study stands, as the backend derives it from the study's
/// processing runs and image reviews; it is never stored. Declared in the
/// order a radiologist should attend to them, which is also the order the
/// worklist sorts by (DL D-024).
enum StudyStatus {
  /// No image got through its view check, so the study has nothing usable.
  /// It stays failed after its failures are discarded, until an upload adds
  /// images.
  failed('Failed'),

  /// An image waits for a radiologist's review.
  needsReview('Needs review'),

  /// A run is under way, or a review decision is being applied.
  processing('Processing'),

  /// Waiting for a worker.
  queued('Queued'),

  /// Done, possibly with open failures.
  ready('Ready');

  const StudyStatus(this.label);

  final String label;

  /// Whether the status can change without anyone acting on the study: what
  /// keeps the worklist reading it again.
  bool get inProgress => this == queued || this == processing;
}

class CaseSummary {
  const CaseSummary({
    required this.id,
    required this.title,
    required this.patient,
    required this.modality,
    required this.date,
    required this.confidence,
    required this.severity,
    this.status = StudyStatus.ready,
    this.openFailures = 0,
    this.activeRunId,
  });

  final String id;
  final String title;
  final String patient;
  final String modality;
  final DateTime date;

  /// 0–1; rendered as a percentage.
  final double confidence;
  final SeverityLevel severity;

  /// Where the study stands (DL D-024).
  final StudyStatus status;

  /// The study's failed steps, across all its runs, waiting to be retried
  /// or discarded. A ready study can have some.
  final int openFailures;

  /// The study's run that still has work left: the one its progress
  /// follows. Of several, the latest created that has started a step, else
  /// the latest created, so a processing study points at a run in progress
  /// and a queued one at a queued run. Null when no run has work left.
  final String? activeRunId;

  /// How the status reads in a list: "Ready", "Ready · 1 failed item",
  /// "Processing · 3 failed items". Plain words, never a status color: a
  /// worklist row also carries severity (DL D-024).
  String get statusSummary => switch (openFailures) {
        0 => status.label,
        1 => '${status.label} · 1 failed item',
        final count => '${status.label} · $count failed items',
      };

  /// The same study with the status the backend derived for it.
  CaseSummary withStatus({
    required StudyStatus status,
    required int openFailures,
    required String? activeRunId,
  }) =>
      CaseSummary(
        id: id,
        title: title,
        patient: patient,
        modality: modality,
        date: date,
        confidence: confidence,
        severity: severity,
        status: status,
        openFailures: openFailures,
        activeRunId: activeRunId,
      );
}

/// What a real case-detail endpoint would plausibly return: the case plus
/// its image. Findings are a separate endpoint/repository (`FindingsRepository`),
/// not merged in here — `CaseService.getCaseDetail` is what combines them.
class CaseDetail {
  const CaseDetail({required this.caseSummary, required this.imageUrl});

  final CaseSummary caseSummary;
  final String imageUrl;
}

/// What a similar-cases search returns: the cases, and which of the source
/// study's images the search was based on. An image held back for review is
/// left out of the search until its review is applied, so a study can be
/// searched with only part of its images, or none.
class SimilarCases {
  const SimilarCases({
    required this.cases,
    required this.imagesUsed,
    required this.imagesTotal,
    required this.imagesHeldBack,
  });

  final List<CaseSummary> cases;
  final int imagesUsed;
  final int imagesTotal;
  final int imagesHeldBack;
}
