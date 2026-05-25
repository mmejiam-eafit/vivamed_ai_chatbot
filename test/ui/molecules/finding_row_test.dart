import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/finding_row.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const labels = {
    SeverityLevel.normal: 'NORMAL',
    SeverityLevel.mild: 'MILD',
    SeverityLevel.moderate: 'MODERATE',
    SeverityLevel.critical: 'CRITICAL',
  };

  // ── Name ───────────────────────────────────────────────────────────────────

  testWidgets('finding name is shown', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Consolidation',
      severity: SeverityLevel.moderate,
    )));
    expect(find.text('Consolidation'), findsOneWidget);
  });

  // ── Severity labels ────────────────────────────────────────────────────────

  for (final entry in labels.entries) {
    testWidgets('${entry.key}: shows ${entry.value} label', (tester) async {
      await tester.pumpWidget(wrap(FindingRow(
        name: 'Finding',
        severity: entry.key,
      )));
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  // ── Expand icon ────────────────────────────────────────────────────────────

  testWidgets('isExpanded: false shows expand_more icon', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
    )));
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsNothing);
  });

  testWidgets('isExpanded: true shows expand_less icon', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
      isExpanded: true,
    )));
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  // ── onTap callback ─────────────────────────────────────────────────────────

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(FindingRow(
      name: 'Finding',
      severity: SeverityLevel.critical,
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(called, isTrue);
  });

  // ── SeverityDot ────────────────────────────────────────────────────────────

  testWidgets('contains a SeverityDot', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.normal,
    )));
    expect(find.byType(SeverityDot), findsOneWidget);
  });
}
