import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

Icon _findDot(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon));

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── SeverityLevel color mapping ────────────────────────────────────────────

  testWidgets('normal maps to SeverityTokens.normal', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.normal)));
    expect(_findDot(tester).color, SeverityTokens.normal);
  });

  testWidgets('mild maps to SeverityTokens.mild', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.mild)));
    expect(_findDot(tester).color, SeverityTokens.mild);
  });

  testWidgets('moderate maps to SeverityTokens.moderate', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.moderate)));
    expect(_findDot(tester).color, SeverityTokens.moderate);
  });

  testWidgets('critical maps to SeverityTokens.critical', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.critical)));
    expect(_findDot(tester).color, SeverityTokens.critical);
  });

  // ── Size ───────────────────────────────────────────────────────────────────

  testWidgets('defaults to size 8.0', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.normal)));
    expect(_findDot(tester).size, 8.0);
  });

  testWidgets('reflects custom size', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.normal, size: 16.0)));
    expect(_findDot(tester).size, 16.0);
  });

  // ── Shape ──────────────────────────────────────────────────────────────────
  // Every level renders a distinct silhouette, never hue alone (DL §3.6, D-003).

  testWidgets('normal renders a circle', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.normal)));
    expect(_findDot(tester).icon, Icons.circle);
  });

  testWidgets('mild renders a square', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.mild)));
    expect(_findDot(tester).icon, Icons.square);
  });

  testWidgets('moderate renders a triangle', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.moderate)));
    expect(_findDot(tester).icon, Icons.change_history);
  });

  testWidgets('critical renders a diamond', (tester) async {
    await tester
        .pumpWidget(wrap(const SeverityDot(severity: SeverityLevel.critical)));
    expect(_findDot(tester).icon, Icons.diamond);
  });

  testWidgets('every level uses a different shape from the others',
      (tester) async {
    final shapes = <IconData>{};
    for (final level in SeverityLevel.values) {
      await tester.pumpWidget(wrap(SeverityDot(severity: level)));
      shapes.add(_findDot(tester).icon!);
    }
    expect(shapes.length, SeverityLevel.values.length);
  });
}
