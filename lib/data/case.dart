import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

class CaseSummary {
  const CaseSummary({
    required this.id,
    required this.title,
    required this.patient,
    required this.modality,
    required this.date,
    required this.confidence,
    required this.severity,
  });

  final String id;
  final String title;
  final String patient;
  final String modality;
  final DateTime date;

  /// 0–1; rendered as a percentage.
  final double confidence;
  final SeverityLevel severity;
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
