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

  /// A search that used every image -- the header's one-line form.
  SimilarCasesCountHeader allImages(int count) => SimilarCasesCountHeader(
        count: count,
        imagesUsed: 1,
        imagesTotal: 1,
        imagesHeldBack: 0,
      );

  // ── Pluralization ──────────────────────────────────────────────────────────

  testWidgets('singular when count is 1', (tester) async {
    await tester.pumpWidget(wrap(allImages(1)));
    expect(find.text('1 similar case found'), findsOneWidget);
  });

  testWidgets('plural when count is greater than 1', (tester) async {
    await tester.pumpWidget(wrap(allImages(3)));
    expect(find.text('3 similar cases found'), findsOneWidget);
  });

  testWidgets('plural when count is 0', (tester) async {
    await tester.pumpWidget(wrap(allImages(0)));
    expect(find.text('0 similar cases found'), findsOneWidget);
  });

  // ── Which images the search used ──────────────────────────────────────────

  testWidgets('no basis line when every image was used', (tester) async {
    await tester.pumpWidget(wrap(allImages(3)));
    expect(find.textContaining('Based on'), findsNothing);
  });

  testWidgets('says how many images were used and held back', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(
      count: 3,
      imagesUsed: 2,
      imagesTotal: 3,
      imagesHeldBack: 1,
    )));
    expect(
      find.text('Based on 2 of 3 images; 1 held back for review'),
      findsOneWidget,
    );
  });

  testWidgets('a single image reads "of 1 image"', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(
      count: 0,
      imagesUsed: 0,
      imagesTotal: 1,
      imagesHeldBack: 1,
    )));
    expect(
      find.text('Based on 0 of 1 image; 1 held back for review'),
      findsOneWidget,
    );
  });

  testWidgets('images left out but none held back omit the review clause',
      (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(
      count: 2,
      imagesUsed: 2,
      imagesTotal: 3,
      imagesHeldBack: 0,
    )));
    expect(find.text('Based on 2 of 3 images'), findsOneWidget);
  });

  // ── Token application ──────────────────────────────────────────────────────

  testWidgets('uses headingSm and textPrimary', (tester) async {
    await tester.pumpWidget(wrap(allImages(2)));
    final text = tester.widget<Text>(find.text('2 similar cases found'));
    expect(text.style?.fontSize, AppTypography.headingSm.fontSize);
    expect(text.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('basis line uses bodyMd and textSecondary', (tester) async {
    await tester.pumpWidget(wrap(const SimilarCasesCountHeader(
      count: 3,
      imagesUsed: 2,
      imagesTotal: 3,
      imagesHeldBack: 1,
    )));
    final text = tester.widget<Text>(find.textContaining('Based on'));
    expect(text.style?.fontSize, AppTypography.bodyMd.fontSize);
    expect(text.style?.color, AppColorsData.light.textSecondary);
  });

  testWidgets('resolves against the dark theme too', (tester) async {
    await tester.pumpWidget(wrap(
      const SimilarCasesCountHeader(
        count: 2,
        imagesUsed: 1,
        imagesTotal: 2,
        imagesHeldBack: 1,
      ),
      brightness: Brightness.dark,
    ));
    final heading = tester.widget<Text>(find.text('2 similar cases found'));
    final basis = tester.widget<Text>(find.textContaining('Based on'));
    expect(heading.style?.color, AppColorsData.dark.textPrimary);
    expect(basis.style?.color, AppColorsData.dark.textSecondary);
  });
}
