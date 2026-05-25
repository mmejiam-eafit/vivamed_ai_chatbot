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
      expect(dec.color, SeverityChip.bgFor(level));
    });
  }

  // ── Label color ────────────────────────────────────────────────────────────

  for (final level in SeverityLevel.values) {
    testWidgets('$level: label uses correct foreground color', (tester) async {
      await tester.pumpWidget(wrap(SeverityChip(severity: level)));
      final text = tester.widget<Text>(find.text(SeverityChip.labelFor(level)));
      expect(text.style?.color, SeverityChip.colorFor(level));
    });
  }

  // ── SeverityDot ────────────────────────────────────────────────────────────

  testWidgets('contains a SeverityDot', (tester) async {
    await tester.pumpWidget(wrap(const SeverityChip(severity: SeverityLevel.moderate)));
    expect(find.byType(SeverityDot), findsOneWidget);
  });
}
