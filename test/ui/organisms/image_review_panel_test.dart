import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/organisms/image_review_panel.dart';

const _disagreeing = RecordedLabels(
  viewPosition: ImageView.ll,
  orientation: ImageOrientation.frontal,
);
const _agreeing = RecordedLabels(
  viewPosition: ImageView.pa,
  orientation: ImageOrientation.frontal,
);

ImageReview _review({
  ReviewStatus status = ReviewStatus.pending,
  ReviewReason reason = ReviewReason.viewLabelsDisagree,
  RecordedLabels recorded = _disagreeing,
  ReviewDecision? decision,
}) =>
    ImageReview(
      id: 'review-1',
      status: status,
      reason: reason,
      image: StudyImage(id: 'image-1', url: 'u', recorded: recorded),
      caseId: 'case-1',
      otherImages: const [],
      report: const [],
      decision: decision,
    );

final _confirmedDecision = ReviewDecision(
  outcome: ReviewOutcome.confirmed,
  decidedBy: 'Dr. J. Okafor',
  decidedAt: DateTime.utc(2026, 10, 26, 15, 40),
);

void main() {
  Widget wrap(
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
  }) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  // By label, not by visible text: a loading AppButton shows a spinner in
  // place of its label.
  Finder buttonFinder(String label) =>
      find.byWidgetPredicate((w) => w is AppButton && w.label == label);

  Finder saveButton() => buttonFinder('Save decision');

  AppButton button(WidgetTester tester, String label) =>
      tester.widget<AppButton>(buttonFinder(label));

  /// A choice in the decision form, not the same words elsewhere (the
  /// recorded labels read "Frontal", "File header" and "Dataset" too).
  Finder option(String text) => find.descendant(
        of: find.byWidgetPredicate((w) => w is RadioListTile),
        matching: find.text(text),
      );

  Finder radioTiles() => find.byWidgetPredicate((w) => w is RadioListTile);

  Future<void> choose(WidgetTester tester, String text) async {
    await tester.ensureVisible(option(text));
    await tester.tap(option(text));
    await tester.pump();
  }

  group('why it was flagged', () {
    testWidgets('shows the status, the reason and both recorded labels',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));

      expect(find.byType(ReviewStatusChip), findsOneWidget);
      expect(find.text('Needs review'), findsOneWidget);
      expect(find.text('The two view labels disagree'), findsOneWidget);
      // Each label appears again as the tag on the choice it matches.
      expect(find.text('File header'), findsWidgets);
      expect(find.text('Left lateral (LL)'), findsWidgets);
      expect(find.text('Dataset'), findsWidgets);
      expect(find.text('Frontal'), findsWidgets);
    });

    for (final reason in ReviewReason.values) {
      testWidgets('shows the reason ${reason.name}', (tester) async {
        await tester.pumpWidget(wrap(ImageReviewPanel(
          review: _review(reason: reason),
          canDecide: true,
          onSave: (_) {},
        )));
        expect(find.text(reason.label), findsOneWidget);
      });
    }

    testWidgets('a missing label reads "Not recorded"', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(recorded: const RecordedLabels()),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.text('Not recorded'), findsNWidgets(2));
    });
  });

  group('deciding', () {
    testWidgets('offers every view and Unusable', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));

      for (final text in [
        'PA',
        'AP',
        'Left lateral (LL)',
        'Right lateral (RL)',
        'Frontal',
        'Lateral',
        'Unusable',
      ]) {
        expect(option(text), findsOneWidget, reason: text);
      }
      expect(radioTiles(), findsNWidgets(7));
    });

    testWidgets('marks which choices match the recorded labels',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(
        find.descendant(
          of: find.ancestor(
            of: option('Left lateral (LL)'),
            matching: find.byWidgetPredicate((w) => w is RadioListTile),
          ),
          matching: find.text('File header'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: option('Frontal'),
            matching: find.byWidgetPredicate((w) => w is RadioListTile),
          ),
          matching: find.text('Dataset'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no "recorded view is correct" when the labels disagree',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.textContaining('Recorded view is correct'), findsNothing);
    });

    testWidgets('"recorded view is correct" names the view when they agree',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(recorded: _agreeing),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(option('Recorded view is correct (PA)'), findsOneWidget);
      expect(radioTiles(), findsNWidgets(8));
    });

    testWidgets('Save is disabled until a choice is made', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(button(tester, 'Save decision').onPressed, isNull);

      await choose(tester, 'Frontal');

      expect(button(tester, 'Save decision').onPressed, isNotNull);
    });

    testWidgets('choosing a view and saving sends setView with that view',
        (tester) async {
      ReviewDecisionDraft? saved;
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (draft) => saved = draft,
      )));

      await choose(tester, 'Frontal');
      await tester.ensureVisible(saveButton());
      await tester.tap(saveButton());

      expect(saved!.outcome, ReviewOutcome.setView);
      expect(saved!.view, ImageView.frontal);
      expect(saved!.note, isNull);
    });

    testWidgets('Unusable sends no view, and the note trimmed', (tester) async {
      ReviewDecisionDraft? saved;
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(reason: ReviewReason.imageBlank),
        canDecide: true,
        onSave: (draft) => saved = draft,
      )));

      await choose(tester, 'Unusable');
      await tester.enterText(find.byType(TextField), '  Nothing on it  ');
      await tester.ensureVisible(saveButton());
      await tester.tap(saveButton());

      expect(saved!.outcome, ReviewOutcome.unusable);
      expect(saved!.view, isNull);
      expect(saved!.note, 'Nothing on it');
    });

    testWidgets('confirming sends confirmed with no view', (tester) async {
      ReviewDecisionDraft? saved;
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(recorded: _agreeing),
        canDecide: true,
        onSave: (draft) => saved = draft,
      )));

      await choose(tester, 'Recorded view is correct (PA)');
      await tester.ensureVisible(saveButton());
      await tester.tap(saveButton());

      expect(saved!.outcome, ReviewOutcome.confirmed);
      expect(saved!.view, isNull);
    });

    testWidgets('while saving, Save shows its spinner and nothing is editable',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
        isSaving: true,
      )));

      expect(button(tester, 'Save decision').isLoading, isTrue);
      expect(button(tester, 'Save decision').onPressed, isNull);
      for (final element in radioTiles().evaluate()) {
        expect((element.widget as RadioListTile).enabled, isFalse);
      }
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('a failed save shows its error', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
        errorMessage: 'Could not save the decision: offline',
      )));

      final banner = tester.widget<StatusBanner>(find.byType(StatusBanner));
      expect(banner.variant, StatusBannerVariant.error);
      expect(find.text('Could not save the decision: offline'), findsOneWidget);
    });

    testWidgets('no error banner without an error', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.byType(StatusBanner), findsNothing);
    });
  });

  group('a decision already made', () {
    testWidgets('shows what was decided, by whom and when', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          recorded: _agreeing,
          decision: _confirmedDecision,
        ),
        canDecide: true,
        onSave: (_) {},
      )));

      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Recorded view confirmed'), findsOneWidget);
      expect(find.text('Dr. J. Okafor'), findsOneWidget);
      expect(find.text('2026-10-26 15:40 UTC'), findsOneWidget);
      expect(find.text('Applied at'), findsNothing);
      expect(radioTiles(), findsNothing);
    });

    testWidgets('a set view and a note read in full', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          decision: ReviewDecision(
            outcome: ReviewOutcome.setView,
            view: ImageView.ll,
            note: 'True lateral',
            decidedBy: 'Dr. A',
            decidedAt: DateTime.utc(2026),
          ),
        ),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.text('View set to Left lateral (LL)'), findsOneWidget);
      expect(find.text('Note: True lateral'), findsOneWidget);
    });

    testWidgets('unusable reads as marked unusable', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          decision: ReviewDecision(
            outcome: ReviewOutcome.unusable,
            decidedBy: 'Dr. A',
            decidedAt: DateTime.utc(2026),
          ),
        ),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.text('Marked unusable'), findsOneWidget);
    });

    testWidgets('an applied decision shows when it was applied',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.applied,
          recorded: _agreeing,
          decision: ReviewDecision(
            outcome: ReviewOutcome.confirmed,
            decidedBy: 'Dr. J. Okafor',
            decidedAt: DateTime.utc(2026, 10, 24, 10, 5),
            appliedAt: DateTime.utc(2026, 10, 24, 10, 20),
          ),
        ),
        canDecide: true,
        onSave: (_) {},
      )));
      expect(find.text('Applied'), findsOneWidget);
      expect(find.text('2026-10-24 10:20 UTC'), findsOneWidget);
    });

    testWidgets('Change decision opens the form with the decision chosen',
        (tester) async {
      ReviewDecisionDraft? saved;
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          recorded: _agreeing,
          decision: _confirmedDecision,
        ),
        canDecide: true,
        onSave: (draft) => saved = draft,
      )));

      await tester.tap(find.text('Change decision'));
      await tester.pump();

      expect(option('Recorded view is correct (PA)'), findsOneWidget);
      expect(button(tester, 'Save decision').onPressed, isNotNull,
          reason: 'the existing decision is already chosen');
      await choose(tester, 'AP');
      await tester.ensureVisible(saveButton());
      await tester.tap(saveButton());
      expect(saved!.view, ImageView.ap);
    });

    testWidgets('Cancel closes the form and keeps the decision',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          recorded: _agreeing,
          decision: _confirmedDecision,
        ),
        canDecide: true,
        onSave: (_) {},
      )));

      await tester.tap(find.text('Change decision'));
      await tester.pump();
      await choose(tester, 'AP');
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(find.text('Recorded view confirmed'), findsOneWidget);
      expect(find.text('Change decision'), findsOneWidget);
    });
  });

  group('read-only, for anyone but a radiologist', () {
    testWidgets('opens the form once the radiologist is known', (tester) async {
      // The signed-in user loads separately from the review, so the panel can
      // be built read-only first and learn it may decide a moment later.
      Widget panel(bool canDecide) => wrap(ImageReviewPanel(
            review: _review(),
            canDecide: canDecide,
            onSave: (_) {},
          ));
      await tester.pumpWidget(panel(false));
      expect(radioTiles(), findsNothing);

      await tester.pumpWidget(panel(true));

      expect(radioTiles(), findsNWidgets(7));
    });

    testWidgets('a review waiting for a decision offers no form',
        (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(),
        canDecide: false,
        onSave: (_) {},
      )));
      expect(radioTiles(), findsNothing);
      expect(find.text('Save decision'), findsNothing);
      expect(
          find.textContaining('Only radiologists can record'), findsOneWidget);
    });

    testWidgets('a decision shows without Change decision', (tester) async {
      await tester.pumpWidget(wrap(ImageReviewPanel(
        review: _review(
          status: ReviewStatus.decided,
          recorded: _agreeing,
          decision: _confirmedDecision,
        ),
        canDecide: false,
        onSave: (_) {},
      )));
      expect(find.text('Recorded view confirmed'), findsOneWidget);
      expect(find.text('Change decision'), findsNothing);
      expect(find.text('Only radiologists can change a decision.'),
          findsOneWidget);
    });
  });

  group('rendering', () {
    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(wrap(
        ImageReviewPanel(review: _review(), canDecide: true, onSave: (_) {}),
        brightness: Brightness.dark,
      ));
      final reason =
          tester.widget<Text>(find.text('The two view labels disagree'));
      expect(reason.style?.color, AppColorsData.dark.textPrimary);
    });

    testWidgets('200% text at a phone width lays out without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(
        ImageReviewPanel(
          review: _review(
            status: ReviewStatus.applied,
            recorded: _agreeing,
            decision: ReviewDecision(
              outcome: ReviewOutcome.setView,
              view: ImageView.rl,
              note: 'A note long enough to need more than one line here',
              decidedBy: 'Dr. J. Okafor',
              decidedAt: DateTime.utc(2026, 10, 24, 10, 5),
              appliedAt: DateTime.utc(2026, 10, 24, 10, 20),
            ),
          ),
          canDecide: true,
          onSave: (_) {},
        ),
        textScale: 2.0,
      ));
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Change decision'));
      await tester.tap(find.text('Change decision'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
