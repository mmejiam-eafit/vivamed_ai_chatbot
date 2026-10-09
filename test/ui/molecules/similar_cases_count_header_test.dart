import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/similar_cases_count_header.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  // ── Pluralization ──────────────────────────────────────────────────────────

  testWidgets('singular when count is 1', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(count: 1)));
    expect(find.text('1 similar case found'), findsOneWidget);
  });

  testWidgets('plural when count is greater than 1', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(count: 3)));
    expect(find.text('3 similar cases found'), findsOneWidget);
  });

  testWidgets('plural when count is 0', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(count: 0)));
    expect(find.text('0 similar cases found'), findsOneWidget);
  });

  // ── Token application ──────────────────────────────────────────────────────

  testWidgets('uses headingSm and textPrimary', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(count: 2)));
    final text = tester.widget<Text>(find.text('2 similar cases found'));
    expect(text.style?.fontSize, AppTypography.headingSm.fontSize);
    expect(text.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('resolves against the dark theme too', (tester) async {
    await tester.pumpWidget(wrap(
      const SimilarCasesCountHeader(count: 2),
      brightness: Brightness.dark,
    ));
    final text = tester.widget<Text>(find.text('2 similar cases found'));
    expect(text.style?.color, AppColorsData.dark.textPrimary);
  });
}
