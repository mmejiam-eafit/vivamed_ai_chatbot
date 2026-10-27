import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/image_review_table.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/image_review_page.dart';
import 'package:radiologist_helper/ui/pages/review_queue_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_image_review_repository.dart';

class _PendingReviewRepository implements ImageReviewRepository {
  @override
  Future<List<ImageReview>> getReviews() =>
      Completer<List<ImageReview>>().future;

  @override
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) =>
      throw UnimplementedError();
}

class _FailingReviewRepository implements ImageReviewRepository {
  @override
  Future<List<ImageReview>> getReviews() async => throw Exception('offline');

  @override
  Future<ImageReview> decide(
    String reviewId, {
    required ReviewOutcome outcome,
    ImageView? view,
    String? note,
  }) =>
      throw UnimplementedError();
}

void main() {
  Widget wrap(Widget child, {ImageReviewRepository? reviews}) => ProviderScope(
        overrides: [
          imageReviewRepositoryProvider
              .overrideWithValue(reviews ?? FakeImageReviewRepository()),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Settings is one of the destinations, and it reads
  // ThemeControllerScope.of(context) -- see case_list_page_test.dart.
  Future<Widget> wrapWithNav(Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    return ProviderScope(
      overrides: [
        imageReviewRepositoryProvider
            .overrideWithValue(FakeImageReviewRepository()),
      ],
      child: ThemeControllerScope(
        controller: controller,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      ),
    );
  }

  void setWideSize(WidgetTester tester) {
    tester.view.physicalSize =
        const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders CaseListTemplate titled Review', (tester) async {
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    expect(find.byType(CaseListTemplate), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Review')),
      findsOneWidget,
    );
  });

  testWidgets('one card per review, needs review first', (tester) async {
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    final cards =
        tester.widgetList<StudyInfoCard>(find.byType(StudyInfoCard)).toList();
    expect(cards, hasLength(4));
    expect(cards.first.title, 'Chest X-Ray — PA and Lateral');
    expect(cards.first.fields.first.value, 'Needs review');
    expect(cards.last.fields.first.value, 'Applied');
  });

  testWidgets('a card shows the reason and the recorded labels',
      (tester) async {
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    final card =
        tester.widgetList<StudyInfoCard>(find.byType(StudyInfoCard)).first;
    final fields = {for (final f in card.fields) f.label: f.value};
    expect(fields['Reason'], 'The two view labels disagree');
    expect(fields['Recorded'], 'LL · Frontal');
    expect(fields['Patient'], 'Anonymous 7');
  });

  testWidgets('tapping a card opens its review', (tester) async {
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(StudyInfoCard).first);
    await tester.pumpAndSettle();

    final page = tester.widget<ImageReviewPage>(find.byType(ImageReviewPage));
    expect(page.reviewId, 'review-01');
  });

  testWidgets('expanded: the review table, rows open their review',
      (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    expect(find.byType(ImageReviewTable), findsOneWidget);
    expect(find.byType(StudyInfoCard), findsNothing);

    await tester.tap(find.text('Anonymous 8').first);
    await tester.pumpAndSettle();

    expect(find.byType(ImageReviewPage), findsOneWidget);
  });

  testWidgets('expanded: the drawer marks Review as the current destination',
      (tester) async {
    setWideSize(tester);
    await tester.pumpWidget(wrap(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    final drawer =
        tester.widget<PrimaryNavDrawer>(find.byType(PrimaryNavDrawer));
    expect(drawer.selectedIndex, 3);
  });

  testWidgets('an empty queue says nothing has been flagged', (tester) async {
    await tester.pumpWidget(wrap(
      const ReviewQueuePage(),
      reviews: FakeImageReviewRepository(reviews: const []),
    ));
    await tester.pumpAndSettle();

    expect(
        find.text('No images have been flagged for review.'), findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    await tester.pumpWidget(
        wrap(const ReviewQueuePage(), reviews: _PendingReviewRepository()));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  testWidgets('a failed load shows the error', (tester) async {
    await tester.pumpWidget(
        wrap(const ReviewQueuePage(), reviews: _FailingReviewRepository()));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Could not load the review queue'), findsOneWidget);
  });

  // ── Nav bar (own index 3) ────────────────────────────────────────────

  testWidgets('tapping Studies in the nav bar replaces with CaseListPage',
      (tester) async {
    await tester.pumpWidget(await wrapWithNav(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Studies'));
    await tester.pumpAndSettle();

    expect(find.byType(CaseListPage), findsOneWidget);
    expect(find.byType(ReviewQueuePage), findsNothing);
  });

  testWidgets('tapping Settings in the nav bar replaces with SettingsPage',
      (tester) async {
    await tester.pumpWidget(await wrapWithNav(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('tapping Review, its own destination, stays put', (tester) async {
    await tester.pumpWidget(await wrapWithNav(const ReviewQueuePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Review'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewQueuePage), findsOneWidget);
  });
}
