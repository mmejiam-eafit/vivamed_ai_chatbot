import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    FindingItem(name: 'Right lower lobe consolidation', severity: SeverityLevel.moderate),
    FindingItem(name: 'Tension pneumothorax', severity: SeverityLevel.critical),
    FindingItem(name: 'Cardiac silhouette — normal', severity: SeverityLevel.normal),
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
      findings: [FindingItem(name: 'Pneumonia', severity: SeverityLevel.moderate)],
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
      findings: [FindingItem(name: 'Pneumonia', severity: SeverityLevel.moderate)],
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
          FindingItem(name: 'Finding 1', severity: SeverityLevel.critical),
          FindingItem(name: 'Finding 2', severity: SeverityLevel.moderate),
          FindingItem(name: 'Finding 3', severity: SeverityLevel.mild),
          FindingItem(name: 'Finding 4', severity: SeverityLevel.normal),
          FindingItem(name: 'Finding 5', severity: SeverityLevel.critical),
          FindingItem(name: 'Finding 6', severity: SeverityLevel.moderate),
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
}
