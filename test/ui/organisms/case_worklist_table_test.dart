import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';

void main() {
  final cases = [
    CaseSummary(
      id: 'case-b',
      title: 'Case B',
      patient: 'Beatrix Kiddo',
      modality: 'CT',
      date: DateTime(2026, 1, 1),
      confidence: 0.50,
      severity: SeverityLevel.moderate,
    ),
    CaseSummary(
      id: 'case-a',
      title: 'Case A',
      patient: 'Aaron Cross',
      modality: 'CXR',
      date: DateTime(2026, 3, 1),
      confidence: 0.90,
      severity: SeverityLevel.critical,
    ),
    CaseSummary(
      id: 'case-c',
      title: 'Case C',
      patient: 'Cameron Poe',
      modality: 'MRI',
      date: DateTime(2026, 2, 1),
      confidence: 0.10,
      severity: SeverityLevel.normal,
    ),
  ];

  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  DataTable table(WidgetTester tester) =>
      tester.widget<DataTable>(find.byType(DataTable));

  testWidgets('renders every patient name', (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    expect(find.text('Beatrix Kiddo'), findsOneWidget);
    expect(find.text('Aaron Cross'), findsOneWidget);
    expect(find.text('Cameron Poe'), findsOneWidget);
  });

  testWidgets('renders empty list without error', (tester) async {
    await tester.pumpWidget(wrap(const CaseWorklistTable(cases: [], heldBack: {})));
    expect(tester.takeException(), isNull);
    expect(find.byType(DataRow), findsNothing);
  });

  // ── D-010: reflow, not clipping (gap 17) ───────────────────────────────────

  testWidgets('dataRowMaxHeight is infinite — rows grow instead of clipping',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    expect(table(tester).dataRowMaxHeight, double.infinity);
  });

  testWidgets('every column has an explicit FlexColumnWidth', (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    for (final column in table(tester).columns) {
      expect(column.columnWidth, isA<FlexColumnWidth>());
    }
  });

  testWidgets('survives 200% text scale with no exception', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Scaffold(body: CaseWorklistTable(cases: cases, heldBack: const {})),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Beatrix Kiddo'), findsOneWidget);
  });

  // ── Sorting ─────────────────────────────────────────────────────────────

  testWidgets('tapping a header sorts ascending by that column',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    await tester.tap(find.text('Patient'));
    await tester.pump();

    final names = tester
        .widgetList<Text>(find.descendant(
          of: find.byType(DataTable),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    final aaronIndex = names.indexOf('Aaron Cross');
    final beatrixIndex = names.indexOf('Beatrix Kiddo');
    final cameronIndex = names.indexOf('Cameron Poe');
    expect(aaronIndex, lessThan(beatrixIndex));
    expect(beatrixIndex, lessThan(cameronIndex));
  });

  testWidgets('tapping the same header again reverses to descending',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    await tester.tap(find.text('Patient'));
    await tester.pump();
    await tester.tap(find.text('Patient'));
    await tester.pump();

    expect(table(tester).sortAscending, isFalse);
    expect(table(tester).sortColumnIndex, 0);
  });

  testWidgets('tapping a different header resets to ascending on it',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    await tester.tap(find.text('Patient'));
    await tester.pump();
    await tester.tap(find.text('Patient'));
    await tester.pump();
    await tester.tap(find.text('Modality'));
    await tester.pump();

    expect(table(tester).sortAscending, isTrue);
    expect(table(tester).sortColumnIndex, 1);
  });

  // ── Severity / confidence / date rendering ─────────────────────────────────

  testWidgets('severity renders as a SeverityChip with the level label',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('MODERATE'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
  });

  testWidgets('confidence renders as a rounded percentage in numeric style',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    final text = tester.widget<Text>(find.text('90%'));
    expect(text.style?.fontFamily, AppTypography.numeric.fontFamily);
  });

  testWidgets('date renders formatted in numeric style', (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    final text = tester.widget<Text>(find.text('2026-03-01'));
    expect(text.style?.fontFamily, AppTypography.numeric.fontFamily);
  });

  // ── Review column (DL D-022) ───────────────────────────────────────────

  ImageReview review(String caseId, ReviewStatus status) => ImageReview(
        id: 'review-$caseId-${status.name}',
        status: status,
        reason: ReviewReason.imageBlank,
        image: const StudyImage(id: 'i', url: 'u', recorded: RecordedLabels()),
        caseId: caseId,
        otherImages: const [],
        report: const [],
      );

  testWidgets('the Review column says what each study holds back',
      (tester) async {
    await tester.pumpWidget(wrap(CaseWorklistTable(
      cases: cases,
      heldBack: {
        'case-a': [review('case-a', ReviewStatus.pending)],
        'case-b': [
          review('case-b', ReviewStatus.pending),
          review('case-b', ReviewStatus.decided),
        ],
      },
    )));
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('1 awaiting review'), findsOneWidget);
    expect(find.text('1 awaiting review, 1 processing'), findsOneWidget);
  });

  testWidgets('the Review column is neutral text, never a status chip',
      (tester) async {
    await tester.pumpWidget(wrap(CaseWorklistTable(
      cases: cases,
      heldBack: {
        'case-a': [review('case-a', ReviewStatus.pending)],
      },
    )));
    expect(find.byType(ReviewStatusChip), findsNothing);
    final text = tester.widget<Text>(find.text('1 awaiting review'));
    expect(text.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('sorting by Review orders by how many images are held back',
      (tester) async {
    await tester.pumpWidget(wrap(CaseWorklistTable(
      cases: cases,
      heldBack: {
        'case-b': [
          review('case-b', ReviewStatus.pending),
          review('case-b', ReviewStatus.decided),
        ],
        'case-c': [review('case-c', ReviewStatus.pending)],
      },
    )));
    await tester.tap(find.text('Review'));
    await tester.pump();
    await tester.tap(find.text('Review'));
    await tester.pump();

    final rows = table(tester).rows;
    final patients = [
      for (final row in rows)
        (tester.widget<Text>(find.descendant(
          of: find.byWidget(row.cells.first.child),
          matching: find.byType(Text),
        ))).data,
    ];
    expect(patients.first, cases.firstWhere((c) => c.id == 'case-b').patient);
    expect(patients[1], cases.firstWhere((c) => c.id == 'case-c').patient);
  });

  // ── onCaseTap (Case List → Study Review) ───────────────────────────────

  testWidgets('tapping a row calls onCaseTap with that case', (tester) async {
    CaseSummary? tapped;
    await tester.pumpWidget(wrap(CaseWorklistTable(
      cases: cases,
      heldBack: const {},
      onCaseTap: (c) => tapped = c,
    )));
    await tester.tap(find.text('Aaron Cross'));
    await tester.pump();
    expect(tapped?.id, 'case-a');
  });

  testWidgets('rows are not selectable when onCaseTap is not provided',
      (tester) async {
    await tester.pumpWidget(wrap(
        CaseWorklistTable(cases: cases, heldBack: const {})));
    for (final row in table(tester).rows) {
      expect(row.onSelectChanged, isNull);
    }
  });

  // ── Dark theme ──────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      CaseWorklistTable(cases: cases, heldBack: const {}),
      brightness: Brightness.dark,
    ));
    final text = tester.widget<Text>(find.text('Aaron Cross'));
    expect(text.style?.color, AppColorsData.dark.textPrimary);

    final theme = tester.widget<Theme>(find.ancestor(
      of: find.byType(DataTable),
      matching: find.byType(Theme),
    ).first);
    expect(theme.data.dividerColor, AppColorsData.dark.borderSubdued);
  });
}
