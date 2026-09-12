import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

final mockCases = <CaseSummary>[
  CaseSummary(
    id: 'case-1',
    title: 'Chest X-Ray',
    patient: 'Anonymous 1',
    modality: 'CXR',
    date: DateTime(2026, 4, 12),
    confidence: 0.94,
    severity: SeverityLevel.moderate,
  ),
  CaseSummary(
    id: 'case-2',
    title: 'Abdominal CT',
    patient: 'Anonymous 2',
    modality: 'CT',
    date: DateTime(2026, 3, 5),
    confidence: 0.78,
    severity: SeverityLevel.normal,
  ),
  CaseSummary(
    id: 'case-3',
    title: 'Chest CT — Lung Nodule',
    patient: 'Anonymous 3',
    modality: 'CT',
    date: DateTime(2026, 2, 18),
    confidence: 0.89,
    severity: SeverityLevel.critical,
  ),
  CaseSummary(
    id: 'case-4',
    title: 'Brain MRI',
    patient: 'Anonymous 4',
    modality: 'MRI',
    date: DateTime(2026, 1, 27),
    confidence: 0.65,
    severity: SeverityLevel.mild,
  ),
  CaseSummary(
    id: 'case-5',
    title: 'Knee MRI',
    patient: 'Anonymous 5',
    modality: 'MRI',
    date: DateTime(2025, 12, 9),
    confidence: 0.72,
    severity: SeverityLevel.normal,
  ),
  CaseSummary(
    id: 'case-6',
    title: 'Chest X-Ray — Follow-up',
    patient: 'Anonymous 6',
    modality: 'CXR',
    date: DateTime(2025, 11, 30),
    confidence: 0.81,
    severity: SeverityLevel.moderate,
  ),
];

/// Thumbnail (list views) and full-size (case detail) images, both seeded by
/// case id so the same case always resolves to the same picture.
String mockThumbnailUrlFor(String caseId) =>
    'https://picsum.photos/seed/$caseId/160/160';

String mockCaseImageUrlFor(String caseId) =>
    'https://picsum.photos/seed/$caseId/800/800';

final _mockFindings = <String, List<FindingItem>>{
  'case-1': const [
    FindingItem(
      name: 'Right lower lobe consolidation',
      severity: SeverityLevel.moderate,
    ),
    FindingItem(
      name: 'Cardiac silhouette — within normal limits',
      severity: SeverityLevel.normal,
    ),
  ],
  'case-2': const [
    FindingItem(name: 'No acute abdominal findings', severity: SeverityLevel.normal),
  ],
  'case-3': const [
    FindingItem(name: 'Tension pneumothorax', severity: SeverityLevel.critical),
    FindingItem(name: 'Right upper lobe nodule, 8mm', severity: SeverityLevel.mild),
  ],
  'case-4': const [
    FindingItem(name: 'Mild cerebral atrophy', severity: SeverityLevel.mild),
  ],
  'case-5': const [
    FindingItem(name: 'No ligamentous injury', severity: SeverityLevel.normal),
  ],
  'case-6': const [
    FindingItem(name: 'Mild cardiomegaly', severity: SeverityLevel.mild),
    FindingItem(
      name: 'Resolved consolidation since prior study',
      severity: SeverityLevel.normal,
    ),
  ],
};

List<FindingItem> mockFindingsFor(String caseId) =>
    _mockFindings[caseId] ?? const [];
