import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/finding_row.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const sampleFindings = [
    FindingItem(id: 'test-finding', name: 'Right lower lobe consolidation', severity: SeverityLevel.moderate),
    FindingItem(id: 'test-finding', name: 'Tension pneumothorax', severity: SeverityLevel.critical),
    FindingItem(id: 'test-finding', name: 'Cardiac silhouette — normal', severity: SeverityLevel.normal),
  ];

  // ── Content rendering ──────────────────────────────────────────────────────

  testWidgets("renders default panel title 'Findings'", (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [])));
    expect(find.text('Findings'), findsOneWidget);
  });

  testWidgets('renders custom title when provided', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(
      findings: [],
      title: 'AI Findings',
    )));
    expect(find.text('AI Findings'), findsOneWidget);
  });

  testWidgets('renders one FindingRow per finding', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: sampleFindings)));
    expect(find.byType(FindingRow), findsNWidgets(sampleFindings.length));
  });

  testWidgets('renders each finding name', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: sampleFindings)));
    expect(find.text('Right lower lobe consolidation'), findsOneWidget);
    expect(find.text('Tension pneumothorax'), findsOneWidget);
  });

  testWidgets("shows empty-state text when findings list is empty", (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [])));
    expect(find.text('No findings recorded.'), findsOneWidget);
    expect(find.byType(FindingRow), findsNothing);
  });

  testWidgets('tapping a row toggles its expanded icon', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(
      findings: [FindingItem(id: 'test-finding', name: 'Pneumonia', severity: SeverityLevel.moderate)],
    )));

    // Initially all rows show expand_more
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsNothing);

    await tester.tap(find.byType(FindingRow));
    await tester.pump();

    expect(find.byIcon(Icons.expand_more), findsNothing);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });

  testWidgets('tapping an expanded row collapses it', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(
      findings: [FindingItem(id: 'test-finding', name: 'Pneumonia', severity: SeverityLevel.moderate)],
    )));

    // Expand
    await tester.tap(find.byType(FindingRow));
    await tester.pump();
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    // Collapse
    await tester.tap(find.byType(FindingRow));
    await tester.pump();
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  // ── onFindingTap / View Heatmap (Study Review → Heatmap Viewer) ──────────

  testWidgets('View Heatmap is absent while collapsed', (tester) async {
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [
        FindingItem(id: 'f1', name: 'Pneumonia', severity: SeverityLevel.moderate),
      ],
      onFindingTap: (_) {},
    )));

    expect(find.text('View Heatmap'), findsNothing);
  });

  testWidgets('View Heatmap appears once expanded, when onFindingTap is set',
      (tester) async {
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [
        FindingItem(id: 'f1', name: 'Pneumonia', severity: SeverityLevel.moderate),
      ],
      onFindingTap: (_) {},
    )));

    await tester.tap(find.byType(FindingRow));
    await tester.pump();

    expect(find.text('View Heatmap'), findsOneWidget);
  });

  testWidgets('expanding without onFindingTap shows no View Heatmap action',
      (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(
      findings: [
        FindingItem(id: 'f1', name: 'Pneumonia', severity: SeverityLevel.moderate),
      ],
    )));

    await tester.tap(find.byType(FindingRow));
    await tester.pump();

    expect(find.text('View Heatmap'), findsNothing);
  });

  testWidgets('tapping View Heatmap calls onFindingTap with that finding\'s id',
      (tester) async {
    String? tapped;
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [
        FindingItem(id: 'f1', name: 'Pneumonia', severity: SeverityLevel.moderate),
        FindingItem(id: 'f2', name: 'Effusion', severity: SeverityLevel.mild),
      ],
      onFindingTap: (id) => tapped = id,
    )));

    // Expand the second row and use its action.
    await tester.tap(find.text('Effusion'));
    await tester.pump();
    await tester.tap(find.text('View Heatmap'));
    await tester.pump();

    expect(tapped, 'f2');
  });

  // ── Trailing action (Study Review → Similar Cases) ───────────────────────
  // Both or neither: the panel owns the button's styling entirely, so the
  // page supplies only a label and a callback (a page must not style content
  // directly).

  testWidgets('no action button by default', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [])));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('no action button when only actionLabel is set', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(
      findings: [],
      actionLabel: 'View Similar Studies',
    )));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('no action button when only onActionTap is set', (tester) async {
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [],
      onActionTap: () {},
    )));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('shows the action button when both are provided', (tester) async {
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [],
      actionLabel: 'View Similar Studies',
      onActionTap: () {},
    )));
    expect(find.text('View Similar Studies'), findsOneWidget);
  });

  testWidgets('tapping the action button calls onActionTap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(FindingsPanel(
      findings: const [],
      actionLabel: 'View Similar Studies',
      onActionTap: () => called = true,
    )));
    await tester.tap(find.text('View Similar Studies'));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('does not overflow with many findings and an action button in '
      'tight constrained height', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;

    await tester.pumpWidget(wrap(SizedBox(
      width: 360,
      height: 200,
      child: FindingsPanel(
        findings: sampleFindings,
        actionLabel: 'View Similar Studies',
        onActionTap: () {},
      ),
    )));

    FlutterError.onError = prev;
    expect(
      errors.where((e) => e.toString().contains('overflowed')),
      isEmpty,
      reason: 'FindingsPanel must scroll rather than overflow, even with '
          'the action button pinned below it',
    );
  });

  // ── Overflow prevention ────────────────────────────────────────────────────

  testWidgets('does not overflow with many findings in tight constrained height',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;

    await tester.pumpWidget(wrap(const SizedBox(
      width: 360,
      height: 200, // deliberately shorter than 6 findings need (~380px)
      child: FindingsPanel(
        findings: [
          FindingItem(id: 'test-finding', name: 'Finding 1', severity: SeverityLevel.critical),
          FindingItem(id: 'test-finding', name: 'Finding 2', severity: SeverityLevel.moderate),
          FindingItem(id: 'test-finding', name: 'Finding 3', severity: SeverityLevel.mild),
          FindingItem(id: 'test-finding', name: 'Finding 4', severity: SeverityLevel.normal),
          FindingItem(id: 'test-finding', name: 'Finding 5', severity: SeverityLevel.critical),
          FindingItem(id: 'test-finding', name: 'Finding 6', severity: SeverityLevel.moderate),
        ],
      ),
    )));

    FlutterError.onError = prev;
    expect(
      errors.where((e) => e.toString().contains('overflowed')),
      isEmpty,
      reason: 'FindingsPanel must scroll rather than overflow',
    );
  });

  // ── Layer-5 aggregation (DL §5.2) ─────────────────────────────────────────
  //
  // At most one alarm per viewport. Alarm treatment is w600 label voice in a
  // full-chroma pair; the quiet rank is w400 at the same size. Counting w600
  // severity labels therefore counts alarms.

  int alarmCount(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .where((t) =>
          t.style?.fontWeight == FontWeight.w600 &&
          t.data != null &&
          t.data! == t.data!.toUpperCase() &&
          RegExp(r'NORMAL|MILD|MODERATE|CRITICAL').hasMatch(t.data!))
      .length;

  testWidgets('two criticals aggregate into one alarm', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [
      FindingItem(id: 'test-finding', name: 'Tension pneumothorax', severity: SeverityLevel.critical),
      FindingItem(id: 'test-finding', name: 'Aortic dissection', severity: SeverityLevel.critical),
      FindingItem(id: 'test-finding', name: 'Mild cardiomegaly', severity: SeverityLevel.mild),
    ])));

    expect(find.text('2 CRITICAL FINDINGS'), findsOneWidget);
    expect(alarmCount(tester), 1, reason: 'the aggregate is the only alarm');
    // Rows are never removed — aggregation changes rank, not presence.
    expect(find.byType(FindingRow), findsNWidgets(3));
  });

  testWidgets('a lone critical keeps its own chip, with no aggregate',
      (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [
      FindingItem(id: 'test-finding', name: 'Tension pneumothorax', severity: SeverityLevel.critical),
      FindingItem(id: 'test-finding', name: 'Mild cardiomegaly', severity: SeverityLevel.mild),
    ])));

    expect(find.textContaining('FINDING'), findsNothing);
    expect(alarmCount(tester), 1, reason: 'the row itself is the one alarm');
    expect(find.text('CRITICAL'), findsOneWidget);
  });

  testWidgets('the aggregate speaks for the highest level present',
      (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [
      FindingItem(id: 'test-finding', name: 'Pleural effusion', severity: SeverityLevel.moderate),
      FindingItem(id: 'test-finding', name: 'Atelectasis', severity: SeverityLevel.moderate),
      FindingItem(id: 'test-finding', name: 'Tension pneumothorax', severity: SeverityLevel.critical),
    ])));

    // One critical outranks two moderates: it is the lone top-level finding,
    // so it keeps its chip and nothing aggregates.
    expect(find.textContaining('FINDINGS'), findsNothing);
    expect(alarmCount(tester), 1);
  });

  testWidgets('no alarm at all when nothing exceeds mild', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [
      FindingItem(id: 'test-finding', name: 'Cardiac silhouette — normal', severity: SeverityLevel.normal),
      FindingItem(id: 'test-finding', name: 'Mild cardiomegaly', severity: SeverityLevel.mild),
    ])));

    expect(alarmCount(tester), 0);
    expect(find.textContaining('FINDING'), findsNothing);
    // Still legible, just not shouted (DL §3.6).
    expect(find.text('NORMAL'), findsOneWidget);
    expect(find.text('MILD'), findsOneWidget);
    expect(find.byType(SeverityDot), findsNWidgets(2));
  });

  testWidgets('three criticals never render three alarms', (tester) async {
    await tester.pumpWidget(wrap(const FindingsPanel(findings: [
      FindingItem(id: 'test-finding', name: 'A', severity: SeverityLevel.critical),
      FindingItem(id: 'test-finding', name: 'B', severity: SeverityLevel.critical),
      FindingItem(id: 'test-finding', name: 'C', severity: SeverityLevel.critical),
    ])));

    expect(find.text('3 CRITICAL FINDINGS'), findsOneWidget);
    expect(alarmCount(tester), 1,
        reason: 'three alarms are indistinguishable from none (DL §5.2)');
  });
}
