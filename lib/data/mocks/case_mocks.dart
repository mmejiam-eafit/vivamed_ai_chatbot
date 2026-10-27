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
  // case-7 and case-8 are CheXpert Plus studies with images held back for
  // review (image_review_mocks.dart). Their confidence and severity are made
  // up like every other case's here.
  CaseSummary(
    id: 'case-7',
    title: 'Chest X-Ray — PA and Lateral',
    patient: 'Anonymous 7',
    modality: 'CXR',
    date: DateTime(2026, 10, 22),
    confidence: 0.76,
    severity: SeverityLevel.mild,
  ),
  CaseSummary(
    id: 'case-8',
    title: 'Chest X-Ray — Semi-upright',
    patient: 'Anonymous 8',
    modality: 'CXR',
    date: DateTime(2026, 10, 20),
    confidence: 0.69,
    severity: SeverityLevel.normal,
  ),
];

/// Thumbnail (list views) and full-size (case detail) images, both seeded by
/// case id so the same case always resolves to the same picture.
///
/// The 3 chest-imaging cases (case-1, case-3, case-6) use a real chest X-ray
/// from the NIH ChestX-ray14 dataset ("ChestXray-NIHCC", a public,
/// de-identified NIH Clinical Center research release) instead of a stock
/// photo -- picked to match that case's finding: case-1's
/// images/case-1.png is images_001/00000112_002.png (labeled Consolidation),
/// case-3's is images_001/00000090_009.png (Pneumothorax), case-6's is
/// images_001/00000008_000.png (Cardiomegaly). The other 3 mock cases are a
/// different body part entirely (abdomen/brain/knee) and keep the placeholder
/// -- AppImage renders either kind of string automatically.
///
/// case-7 and case-8 show a frontal image of their CheXpert Plus study. Those
/// PNGs are converted locally by `make mock-images` and never committed, so on
/// a fresh clone AppImage shows its broken-image placeholder for them.
const _realCaseImages = {
  'case-1': 'lib/data/mocks/images/case-1.png',
  'case-3': 'lib/data/mocks/images/case-3.png',
  'case-6': 'lib/data/mocks/images/case-6.png',
  'case-7': 'lib/data/mocks/images/chexpert/case-7-view1.png',
  'case-8': 'lib/data/mocks/images/chexpert/case-8-view2.png',
};

String mockThumbnailUrlFor(String caseId) =>
    _realCaseImages[caseId] ?? 'https://picsum.photos/seed/$caseId/160/160';

String mockCaseImageUrlFor(String caseId) =>
    _realCaseImages[caseId] ?? 'https://picsum.photos/seed/$caseId/800/800';

/// Which of a study's images the mock similar-case search was based on. The
/// studies with images held back for review (image_review_mocks.dart) are
/// listed; every other mock study has one image, used.
const _similarCasesBasis = {
  'case-6': (used: 0, total: 1, heldBack: 1),
  'case-7': (used: 2, total: 3, heldBack: 1),
  'case-8': (used: 2, total: 3, heldBack: 1),
};

({int used, int total, int heldBack}) mockSimilarCasesBasisFor(
  String caseId,
) =>
    _similarCasesBasis[caseId] ?? (used: 1, total: 1, heldBack: 0);

/// Appends a newly "uploaded" case so it also shows up back in the Studies
/// worklist afterward -- a stand-in for a real backend persisting it.
void addMockCase(CaseSummary newCase) => mockCases.add(newCase);

// Sequential across every case, not per-case, so each finding has a globally
// unique id -- the first 3 pick up heatmap_mocks.dart's existing distinct
// colors, the rest fall back to its default.
final _mockFindings = <String, List<FindingItem>>{
  'case-1': const [
    FindingItem(
      id: 'finding-1',
      name: 'Right lower lobe consolidation',
      severity: SeverityLevel.moderate,
    ),
    FindingItem(
      id: 'finding-2',
      name: 'Cardiac silhouette — within normal limits',
      severity: SeverityLevel.normal,
    ),
  ],
  'case-2': const [
    FindingItem(
      id: 'finding-3',
      name: 'No acute abdominal findings',
      severity: SeverityLevel.normal,
    ),
  ],
  'case-3': const [
    FindingItem(
      id: 'finding-4',
      name: 'Tension pneumothorax',
      severity: SeverityLevel.critical,
    ),
    FindingItem(
      id: 'finding-5',
      name: 'Right upper lobe nodule, 8mm',
      severity: SeverityLevel.mild,
    ),
  ],
  'case-4': const [
    FindingItem(
      id: 'finding-6',
      name: 'Mild cerebral atrophy',
      severity: SeverityLevel.mild,
    ),
  ],
  'case-5': const [
    FindingItem(
      id: 'finding-7',
      name: 'No ligamentous injury',
      severity: SeverityLevel.normal,
    ),
  ],
  'case-6': const [
    FindingItem(
      id: 'finding-8',
      name: 'Mild cardiomegaly',
      severity: SeverityLevel.mild,
    ),
    FindingItem(
      id: 'finding-9',
      name: 'Resolved consolidation since prior study',
      severity: SeverityLevel.normal,
    ),
  ],
};

List<FindingItem> mockFindingsFor(String caseId) =>
    _mockFindings[caseId] ?? const [];
