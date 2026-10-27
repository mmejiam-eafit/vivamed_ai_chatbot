import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/mocks/user_mocks.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/image_review_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/repositories/user_repository.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/captioned_image.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/organisms/image_review_panel.dart';
import 'package:radiologist_helper/ui/pages/image_review_page.dart';
import 'package:radiologist_helper/ui/templates/image_review_template.dart';

import '../../support/fake_image_review_repository.dart';

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.user);

  final UserProfile user;

  @override
  Future<UserProfile> getCurrentUser() async => user;
}

/// Reviews that never arrive, for the loading state.
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

const _technologist = UserProfile(
  name: 'T. Lee',
  role: 'Technologist',
  email: 't@hospital.org',
  initials: 'TL',
);

void main() {
  Widget wrap(
    String reviewId, {
    ImageReviewRepository? reviews,
    UserProfile user = mockCurrentUser,
  }) {
    final List<Override> overrides = [
      imageReviewRepositoryProvider
          .overrideWithValue(reviews ?? FakeImageReviewRepository()),
      userRepositoryProvider.overrideWithValue(_FakeUserRepository(user)),
    ];
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(),
        home: ImageReviewPage(reviewId: reviewId),
      ),
    );
  }

  /// Phone-sized, as in the other page tests' narrow cases: the details
  /// scroll under the canvas.
  void setNarrow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder option(String text) => find.descendant(
        of: find.byWidgetPredicate((w) => w is RadioListTile),
        matching: find.text(text),
      );

  /// The report sits below the panel in the details list, which builds
  /// lazily: scroll it into being before looking for it.
  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first,
      );

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('renders ImageReviewTemplate', (tester) async {
    await tester.pumpWidget(wrap('review-01'));
    await tester.pumpAndSettle();

    expect(find.byType(ImageReviewTemplate), findsOneWidget);
    expect(find.text('Image review'), findsOneWidget);
  });

  testWidgets(
      'shows the flagged image beside the study\'s other images, '
      'each captioned with its recorded labels', (tester) async {
    await tester.pumpWidget(wrap('review-01'));
    await tester.pumpAndSettle();

    expect(find.byType(CaptionedImage), findsNWidgets(3));
    expect(find.text('Flagged · Header LL · Dataset Frontal'), findsOneWidget);
    expect(find.text('Header PA · Dataset Frontal'), findsOneWidget);
    expect(find.text('Header LL · Dataset Lateral'), findsOneWidget);
  });

  testWidgets('shows the study\'s report', (tester) async {
    await tester.pumpWidget(wrap('review-01'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Technique'));

    expect(find.text('Technique'), findsOneWidget);
    expect(find.text('PA and lateral views of the chest.'), findsOneWidget);
  });

  testWidgets('a study with no report says so', (tester) async {
    await tester.pumpWidget(wrap('review-03'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('No report for this study.'));

    expect(find.text('No report for this study.'), findsOneWidget);
    expect(find.byType(CaptionedImage), findsOneWidget);
  });

  testWidgets('a radiologist decides: the review becomes Processing',
      (tester) async {
    setNarrow(tester);
    await tester.pumpWidget(wrap('review-01'));
    await tester.pumpAndSettle();
    expect(find.text('Needs review'), findsOneWidget);

    await tapVisible(tester, option('Frontal'));
    await tapVisible(tester, find.text('Save decision'));

    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('View set to Frontal'), findsOneWidget);
    expect(find.text('Dr. Test'), findsOneWidget);
    expect(find.text('Save decision'), findsNothing);
  });

  testWidgets('the decision reaches the repository', (tester) async {
    setNarrow(tester);
    final repository = FakeImageReviewRepository();
    await tester.pumpWidget(wrap('review-02', reviews: repository));
    await tester.pumpAndSettle();

    await tapVisible(tester, option('Unusable'));
    await tester.enterText(find.byType(TextField), 'Nothing on the film');
    await tapVisible(tester, find.text('Save decision'));

    final saved = repository.reviews.firstWhere((r) => r.id == 'review-02');
    expect(saved.status, ReviewStatus.decided);
    expect(saved.decision!.outcome, ReviewOutcome.unusable);
    expect(saved.decision!.note, 'Nothing on the film');
  });

  testWidgets('a failed save keeps the form open and says why', (tester) async {
    setNarrow(tester);
    await tester.pumpWidget(wrap(
      'review-01',
      reviews: FakeImageReviewRepository(decideError: Exception('offline')),
    ));
    await tester.pumpAndSettle();

    await tapVisible(tester, option('Frontal'));
    await tapVisible(tester, find.text('Save decision'));

    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.text('Could not save the decision: Exception: offline'),
        findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    final panel =
        tester.widget<ImageReviewPanel>(find.byType(ImageReviewPanel));
    expect(panel.isSaving, isFalse);
  });

  testWidgets('anyone but a radiologist sees it read-only', (tester) async {
    await tester.pumpWidget(wrap('review-01', user: _technologist));
    await tester.pumpAndSettle();

    final panel =
        tester.widget<ImageReviewPanel>(find.byType(ImageReviewPanel));
    expect(panel.canDecide, isFalse);
    expect(find.text('Save decision'), findsNothing);
  });

  testWidgets('a radiologist can decide', (tester) async {
    await tester.pumpWidget(wrap('review-01'));
    await tester.pumpAndSettle();

    final panel =
        tester.widget<ImageReviewPanel>(find.byType(ImageReviewPanel));
    expect(panel.canDecide, isTrue);
  });

  testWidgets('a review not in the queue says so', (tester) async {
    await tester.pumpWidget(wrap('review-gone'));
    await tester.pumpAndSettle();

    expect(find.text('This review is no longer in the queue.'), findsOneWidget);
  });

  testWidgets('while the reviews load, shows the loading indicator',
      (tester) async {
    await tester
        .pumpWidget(wrap('review-01', reviews: _PendingReviewRepository()));
    await tester.pump();

    expect(find.byType(ImageReviewTemplate), findsOneWidget);
    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  testWidgets('a failed load shows the error', (tester) async {
    await tester
        .pumpWidget(wrap('review-01', reviews: _FailingReviewRepository()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load the review'), findsOneWidget);
  });
}
