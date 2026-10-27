import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/image_review_page.dart';

import 'fixtures/fixture_result.dart';
import 'fixtures/image_review_repository_fixture.dart';

/// Fixture-backed scenarios: they override `imageReviewRepositoryProvider`,
/// so these assert against the fixture below rather than the mocks.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const pending = ImageReview(
    id: 'fixture-review',
    status: ReviewStatus.pending,
    reason: ReviewReason.viewLabelsDisagree,
    image: StudyImage(
      id: 'fixture-flagged',
      url: 'fixture-missing.png',
      recorded: RecordedLabels(
        viewPosition: ImageView.ll,
        orientation: ImageOrientation.frontal,
      ),
    ),
    caseId: 'fixture-case',
    otherImages: [
      StudyImage(
        id: 'fixture-pa',
        url: 'fixture-missing.png',
        recorded: RecordedLabels(
          viewPosition: ImageView.pa,
          orientation: ImageOrientation.frontal,
        ),
      ),
    ],
    report: [ReportSection(title: 'Technique', text: 'Fixture technique.')],
  );

  final decided = pending.copyWith(
    status: ReviewStatus.decided,
    decision: ReviewDecision(
      outcome: ReviewOutcome.setView,
      view: ImageView.frontal,
      decidedBy: 'Dr. Fixture',
      decidedAt: DateTime.utc(2026, 10, 27, 9),
    ),
  );

  Widget wrap(ImageReviewRepositoryFixture fixture) => ProviderScope(
        overrides: [imageReviewRepositoryProvider.overrideWithValue(fixture)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const ImageReviewPage(reviewId: 'fixture-review'),
        ),
      );

  // Real device runs use the host window, so pin a size: the canvas beside
  // the details, from twoPaneMinWidth.
  void setWideSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(AppLayout.twoPaneMinWidth, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder option(String text) => find.descendant(
        of: find.byWidgetPredicate((w) => w is RadioListTile),
        matching: find.text(text),
      );

  testWidgets('shows the flagged image, its labels and the other images',
      (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureSuccess([pending]),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Flagged · Header LL · Dataset Frontal'), findsOneWidget);
    expect(find.text('Header PA · Dataset Frontal'), findsOneWidget);
  });

  testWidgets('a decision turns the review to Processing', (tester) async {
    setWideSize(tester);
    final fixture = ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureSuccess([pending]),
      decideResult: FixtureSuccess(decided),
    );
    await tester.pumpWidget(wrap(fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(option('Frontal'));
    await tester.tap(option('Frontal'));
    await tester.pumpAndSettle();
    fixture.getReviewsResult = FixtureSuccess([decided]);
    await tester.ensureVisible(find.text('Save decision'));
    await tester.tap(find.text('Save decision'));
    await tester.pumpAndSettle();

    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('View set to Frontal'), findsOneWidget);
    expect(find.text('Dr. Fixture'), findsOneWidget);
  });

  testWidgets('a failed decision keeps the form and says why', (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureSuccess([pending]),
      decideResult: const FixtureFailure('fixture decide failure'),
    )));
    await tester.pumpAndSettle();

    await tester.ensureVisible(option('Frontal'));
    await tester.tap(option('Frontal'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save decision'));
    await tester.tap(find.text('Save decision'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save the decision'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
  });

  testWidgets('failure loading the reviews shows the error', (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixtureFailure('fixture reviews failure'),
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load the review'), findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(ImageReviewRepositoryFixture(
      getReviewsResult: const FixturePending(),
    )));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });
}
