import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';

// Four reviews, one for each state worth seeing. case-7 and case-8 are
// CheXpert Plus studies whose PNGs `make mock-images` converts locally (they
// are research-use data and never committed). Every recorded label below is
// what that image's file header and dataset entry actually say. The report
// text is written for these mocks, not copied from the dataset, and is not a
// reading of the images.

const _chexpert = 'lib/data/mocks/images/chexpert';

// patient29942/study3: a PA, then a second frontal film whose header says
// left lateral, then a true lateral.
const _case7Pa = StudyImage(
  id: 'case-7-image-1',
  url: '$_chexpert/case-7-view1.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.pa,
    orientation: ImageOrientation.frontal,
  ),
);
const _case7Flagged = StudyImage(
  id: 'case-7-image-2',
  url: '$_chexpert/case-7-view2.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.frontal,
  ),
);
const _case7Lateral = StudyImage(
  id: 'case-7-image-3',
  url: '$_chexpert/case-7-view3.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.lateral,
  ),
);
const _case7Report = [
  ReportSection(title: 'Technique', text: 'PA and lateral views of the chest.'),
];

// patient25979/study8: a blank image whose header says left lateral, then an
// AP and a lateral, both semi-upright.
const _case8Blank = StudyImage(
  id: 'case-8-image-1',
  url: '$_chexpert/case-8-view1.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.frontal,
  ),
);
const _case8Ap = StudyImage(
  id: 'case-8-image-2',
  url: '$_chexpert/case-8-view2.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.ap,
    orientation: ImageOrientation.frontal,
  ),
);
const _case8Lateral = StudyImage(
  id: 'case-8-image-3',
  url: '$_chexpert/case-8-view3.png',
  recorded: RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.lateral,
  ),
);
const _case8Report = [
  ReportSection(
    title: 'Technique',
    text: 'Semi-upright portable AP and lateral views of the chest.',
  ),
];

/// Seeds `MockImageReviewRepository`. review-01 and review-02 are two of the
/// real flagged images. review-03 and review-04 flag images that are not
/// blank, so the decided and applied states, and a study held back entirely,
/// have something to show.
final mockImageReviews = <ImageReview>[
  const ImageReview(
    id: 'review-01',
    status: ReviewStatus.pending,
    reason: ReviewReason.viewLabelsDisagree,
    image: _case7Flagged,
    caseId: 'case-7',
    otherImages: [_case7Pa, _case7Lateral],
    report: _case7Report,
  ),
  const ImageReview(
    id: 'review-02',
    status: ReviewStatus.pending,
    reason: ReviewReason.imageBlank,
    image: _case8Blank,
    caseId: 'case-8',
    otherImages: [_case8Ap, _case8Lateral],
    report: _case8Report,
  ),
  // NIH ChestX-ray14 records this image as PA, and every NIH image is
  // frontal, so its labels agree. It is the study's only image, and it has
  // no report.
  ImageReview(
    id: 'review-03',
    status: ReviewStatus.decided,
    reason: ReviewReason.imageBlank,
    image: StudyImage(
      id: 'case-6-image-1',
      url: mockCaseImageUrlFor('case-6'),
      recorded: const RecordedLabels(
        viewPosition: ImageView.pa,
        orientation: ImageOrientation.frontal,
      ),
    ),
    caseId: 'case-6',
    otherImages: const [],
    report: const [],
    decision: ReviewDecision(
      outcome: ReviewOutcome.confirmed,
      decidedBy: 'Dr. J. Okafor',
      decidedAt: DateTime.utc(2026, 10, 26, 15, 40),
    ),
  ),
  ImageReview(
    id: 'review-04',
    status: ReviewStatus.applied,
    reason: ReviewReason.imageBlank,
    image: _case8Ap,
    caseId: 'case-8',
    otherImages: const [_case8Blank, _case8Lateral],
    report: _case8Report,
    decision: ReviewDecision(
      outcome: ReviewOutcome.confirmed,
      decidedBy: 'Dr. J. Okafor',
      decidedAt: DateTime.utc(2026, 10, 24, 10, 5),
      appliedAt: DateTime.utc(2026, 10, 24, 10, 20),
    ),
  ),
];
