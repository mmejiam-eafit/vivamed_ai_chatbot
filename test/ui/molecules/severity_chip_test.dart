import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/severity_chip.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  Container findChipContainer(WidgetTester tester) {
    return tester.widget<Container>(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius != null,
        description: 'chip container',
      ),
    );
  }

  // ── Label text ─────────────────────────────────────────────────────────────

  for (final level in SeverityLevel.values) {
    testWidgets('$level: shows correct label', (tester) async {
      await tester.pumpWidget(wrap(SeverityChip(severity: level)));
      expect(find.text(SeverityChip.labelFor(level)), findsOneWidget);
    });
  }

  // ── Background color ───────────────────────────────────────────────────────

  for (final level in SeverityLevel.values) {
    testWidgets('$level: uses correct background color', (tester) async {
      await tester.pumpWidget(wrap(SeverityChip(severity: level)));
      final dec = findChipContainer(tester).decoration! as BoxDecoration;
      expect(dec.color, SeverityChip.bgFor(SeverityData.light, level));
    });
  }

  // ── Label color ────────────────────────────────────────────────────────────

  for (final level in SeverityLevel.values) {
    testWidgets('$level: label uses correct foreground color', (tester) async {
      await tester.pumpWidget(wrap(SeverityChip(severity: level)));
      final text = tester.widget<Text>(find.text(SeverityChip.labelFor(level)));
      expect(text.style?.color, SeverityChip.colorFor(SeverityData.light, level));
    });
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
          body: SeverityChip(severity: SeverityLevel.critical)),
    ));
    final dec = findChipContainer(tester).decoration! as BoxDecoration;
    expect(dec.color, SeverityData.dark.criticalBg);
    final text = tester.widget<Text>(
        find.text(SeverityChip.labelFor(SeverityLevel.critical)));
    expect(text.style?.color, SeverityData.dark.critical);
  });

  // ── Typography ─────────────────────────────────────────────────────────────

  testWidgets('label renders at or above the 12px clinical floor',
      (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityChip(severity: SeverityLevel.mild)));
    final text = tester.widget<Text>(find.text(SeverityChip.labelFor(SeverityLevel.mild)));
    expect(text.style?.fontSize, greaterThanOrEqualTo(12.0));
  });

  // ── SeverityDot ────────────────────────────────────────────────────────────

  testWidgets('contains a SeverityDot', (tester) async {
    await tester.pumpWidget(wrap(const SeverityChip(severity: SeverityLevel.moderate)));
    expect(find.byType(SeverityDot), findsOneWidget);
  });

  // ── Label override (the aggregated alarm, DL §5.2) ────────────────────────

  testWidgets('label override replaces the level label', (tester) async {
    await tester.pumpWidget(wrap(const SeverityChip(
      severity: SeverityLevel.critical,
      label: '3 CRITICAL FINDINGS',
    )));
    expect(find.text('3 CRITICAL FINDINGS'), findsOneWidget);
    expect(find.text('CRITICAL'), findsNothing);
  });

  testWidgets('override keeps the level\'s own colors', (tester) async {
    await tester.pumpWidget(wrap(const SeverityChip(
      severity: SeverityLevel.critical,
      label: '3 CRITICAL FINDINGS',
    )));
    final dec = findChipContainer(tester).decoration! as BoxDecoration;
    expect(dec.color, SeverityChip.bgFor(SeverityData.light, SeverityLevel.critical));
    final text = tester.widget<Text>(find.text('3 CRITICAL FINDINGS'));
    expect(text.style?.color,
        SeverityChip.colorFor(SeverityData.light, SeverityLevel.critical));
  });
}
