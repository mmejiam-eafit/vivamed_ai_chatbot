import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/severity_chip.dart';
import 'package:radiologist_helper/ui/organisms/image_review_table.dart';

final _case = CaseSummary(
  id: 'case-7',
  title: 'Chest X-Ray — PA and Lateral',
  patient: 'Anonymous 7',
  modality: 'CXR',
  date: DateTime(2026, 10, 22),
  confidence: 0.76,
  severity: SeverityLevel.mild,
);

ReviewQueueItem _item(
  String id,
  ReviewStatus status, {
  ReviewDecision? decision,
  RecordedLabels recorded = const RecordedLabels(
    viewPosition: ImageView.ll,
    orientation: ImageOrientation.frontal,
  ),
}) =>
    (
      review: ImageReview(
        id: id,
        status: status,
        reason: ReviewReason.viewLabelsDisagree,
        image: StudyImage(id: 'image-$id', url: 'u', recorded: recorded),
        caseId: 'case-7',
        otherImages: const [],
        report: const [],
        decision: decision,
      ),
      caseSummary: _case,
    );

ReviewDecision _decided(ReviewOutcome outcome, {ImageView? view}) =>
    ReviewDecision(
      outcome: outcome,
      view: view,
      decidedBy: 'Dr. A',
      decidedAt: DateTime.utc(2026, 10, 27),
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
          child: Scaffold(body: child),
        ),
      );

  void setWide(WidgetTester tester) {
    tester.view.physicalSize = const Size(AppLayout.threePaneMinWidth, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('one row per review, in the order given', (tester) async {
    setWide(tester);
    await tester.pumpWidget(wrap(ImageReviewTable(items: [
      _item('a', ReviewStatus.pending),
      _item('b', ReviewStatus.decided,
          decision: _decided(ReviewOutcome.unusable)),
    ])));

    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.rows, hasLength(2));
    expect(
      tester.getTopLeft(find.text('Needs review')).dy,
      lessThan(tester.getTopLeft(find.text('Processing')).dy),
    );
  });

  testWidgets('shows status, patient, date, reason and recorded labels',
      (tester) async {
    setWide(tester);
    await tester.pumpWidget(
        wrap(ImageReviewTable(items: [_item('a', ReviewStatus.pending)])));

    expect(find.byType(ReviewStatusChip), findsOneWidget);
    expect(find.text('Anonymous 7'), findsOneWidget);
    expect(find.text('2026-10-22'), findsOneWidget);
    expect(find.text('The two view labels disagree'), findsOneWidget);
    expect(find.text('LL · Frontal'), findsOneWidget);
  });

  testWidgets('the date is numeric and the labels mono', (tester) async {
    setWide(tester);
    await tester.pumpWidget(
        wrap(ImageReviewTable(items: [_item('a', ReviewStatus.pending)])));

    final date = tester.widget<Text>(find.text('2026-10-22'));
    final labels = tester.widget<Text>(find.text('LL · Frontal'));
    expect(date.style?.fontFeatures, AppTypography.numeric.fontFeatures);
    expect(labels.style?.fontFamily, AppTypography.mono.fontFamily);
  });

  testWidgets('a missing label shows a dash', (tester) async {
    setWide(tester);
    await tester.pumpWidget(wrap(ImageReviewTable(items: [
      _item('a', ReviewStatus.pending, recorded: const RecordedLabels()),
    ])));
    expect(find.text('— · —'), findsOneWidget);
  });

  group('the decision column', () {
    final cases = {
      'empty while pending': (null, ''),
      'the view when set': (
        _decided(ReviewOutcome.setView, view: ImageView.ll),
        'Left lateral (LL)'
      ),
      'Unusable': (_decided(ReviewOutcome.unusable), 'Unusable'),
      'Confirmed': (_decided(ReviewOutcome.confirmed), 'Confirmed'),
    };
    for (final MapEntry(key: name, value: (decision, text)) in cases.entries) {
      testWidgets(name, (tester) async {
        setWide(tester);
        await tester.pumpWidget(wrap(ImageReviewTable(items: [
          _item(
            'a',
            decision == null ? ReviewStatus.pending : ReviewStatus.decided,
            decision: decision,
          ),
        ])));
        final row =
            tester.widget<DataTable>(find.byType(DataTable)).rows.single;
        final cell = row.cells.last.child;
        expect(
            (tester.widget<Text>(find.descendant(
              of: find.byWidget(cell),
              matching: find.byType(Text),
            ))).data,
            text);
      });
    }
  });

  testWidgets('tapping a row passes its review', (tester) async {
    setWide(tester);
    ImageReview? tapped;
    await tester.pumpWidget(wrap(ImageReviewTable(
      items: [_item('a', ReviewStatus.pending)],
      onReviewTap: (review) => tapped = review,
    )));

    await tester.tap(find.text('Anonymous 7'));

    expect(tapped?.id, 'a');
  });

  testWidgets('rows are not tappable without onReviewTap', (tester) async {
    setWide(tester);
    await tester.pumpWidget(
        wrap(ImageReviewTable(items: [_item('a', ReviewStatus.pending)])));
    final row = tester.widget<DataTable>(find.byType(DataTable)).rows.single;
    expect(row.onSelectChanged, isNull);
  });

  testWidgets('holds no severity (DL D-021)', (tester) async {
    setWide(tester);
    await tester.pumpWidget(
        wrap(ImageReviewTable(items: [_item('a', ReviewStatus.pending)])));
    expect(find.byType(SeverityChip), findsNothing);
  });

  testWidgets('an empty queue renders without error', (tester) async {
    setWide(tester);
    await tester.pumpWidget(wrap(const ImageReviewTable(items: [])));
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolves against the dark theme', (tester) async {
    setWide(tester);
    await tester.pumpWidget(wrap(
      ImageReviewTable(items: [_item('a', ReviewStatus.pending)]),
      brightness: Brightness.dark,
    ));
    final patient = tester.widget<Text>(find.text('Anonymous 7'));
    expect(patient.style?.color, AppColorsData.dark.textPrimary);
  });

  testWidgets('200% text reflows at the narrowest wide width', (tester) async {
    setWide(tester);
    await tester.pumpWidget(wrap(
      ImageReviewTable(items: [
        _item('a', ReviewStatus.pending),
        _item('b', ReviewStatus.applied,
            decision: _decided(ReviewOutcome.setView, view: ImageView.rl)),
      ]),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
