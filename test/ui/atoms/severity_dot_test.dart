import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

Container _findDot(WidgetTester tester) {
  return tester.widget<Container>(
    find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).shape == BoxShape.circle,
    ),
  );
}

Color _dotColor(WidgetTester tester) =>
    (_findDot(tester).decoration! as BoxDecoration).color!;

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── SeverityLevel color mapping ────────────────────────────────────────────

  testWidgets('normal maps to SeverityTokens.normal', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.normal)));
    expect(_dotColor(tester), SeverityTokens.normal);
  });

  testWidgets('mild maps to SeverityTokens.mild', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.mild)));
    expect(_dotColor(tester), SeverityTokens.mild);
  });

  testWidgets('moderate maps to SeverityTokens.moderate', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.moderate)));
    expect(_dotColor(tester), SeverityTokens.moderate);
  });

  testWidgets('critical maps to SeverityTokens.critical', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.critical)));
    expect(_dotColor(tester), SeverityTokens.critical);
  });

  // ── Size ───────────────────────────────────────────────────────────────────

  testWidgets('defaults to size 8.0', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.normal)));
    final dot = _findDot(tester);
    expect(dot.constraints?.maxWidth, 8.0);
  });

  testWidgets('reflects custom size', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.normal, size: 16.0)));
    final dot = _findDot(tester);
    expect(dot.constraints?.maxWidth, 16.0);
  });

  // ── Shape ──────────────────────────────────────────────────────────────────

  testWidgets('renders as a circle', (tester) async {
    await tester.pumpWidget(
        wrap(const SeverityDot(severity: SeverityLevel.normal)));
    final decoration = _findDot(tester).decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
  });
}
