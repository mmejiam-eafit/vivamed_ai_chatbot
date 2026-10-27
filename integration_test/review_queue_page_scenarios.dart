import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/review_queue_page.dart';

import 'fixtures/case_repository_fixture.dart';
import 'fixtures/fixture_result.dart';
import 'fixtures/image_review_repository_fixture.dart';

/// Fixture-backed scenarios: the queue joins each review to its study, so
/// both the review and the case repositories are overridden.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final fixtureCase = CaseSummary(
    id: 'fixture-case',
    title: 'Fixture Flagged Study',
    patient: 'Fixture Patient R',
    modality: 'CXR',
    date: DateTime(2026, 10, 1),
    confidence: 0.7,
    severity: SeverityLevel.mild,
  );

  const pending = ImageReview(
    id: 'fixture-review',
    status: ReviewStatus.pending,
    reason: ReviewReason.imageBlank,
    image: StudyImage(
      id: 'fixture-flagged',
      url: 'fixture-missing.png',
      recorded: RecordedLabels(
        viewPosition: ImageView.ll,
        orientation: ImageOrientation.frontal,
      ),
    ),
    caseId: 'fixture-case',
    otherImages: [],
    report: [],
  );

  Widget wrap(ImageReviewRepositoryFixture reviews) => ProviderScope(
        overrides: [
          imageReviewRepositoryProvider.overrideWithValue(reviews),
          caseRepositoryProvider.overrideWithValue(CaseRepositoryFixture(
            getCasesResult: FixtureSuccess([fixtureCase]),
          )),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const ReviewQueuePage(),
        ),
      );

  // Pinned narrow so CaseListTemplate renders cards, as in the Case List
  // scenarios.
  void setNarrowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('lists a flagged image with its study and reason',
      (tester) async {
    setNarrowSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureSuccess([pending]),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Fixture Flagged Study'), findsOneWidget);
    expect(find.text('The image looks blank'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
  });

  testWidgets('an empty queue says nothing has been flagged', (tester) async {
    setNarrowSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureSuccess([]),
    )));
    await tester.pumpAndSettle();

    expect(
        find.text('No images have been flagged for review.'), findsOneWidget);
  });

  testWidgets('failure shows the error text', (tester) async {
    setNarrowSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureFailure('fixture queue failure'),
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load the review queue'),
        findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    setNarrowSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixturePending(),
    )));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });
}
