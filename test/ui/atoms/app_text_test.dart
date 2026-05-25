import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders text content', (tester) async {
    await tester.pumpWidget(wrap(const AppText('Hello')));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('defaults to bodyMd font size', (tester) async {
    await tester.pumpWidget(wrap(const AppText('Hi')));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.fontSize, AppTypography.bodyMd.fontSize);
  });

  testWidgets('defaults to textPrimary color', (tester) async {
    await tester.pumpWidget(wrap(const AppText('Hi')));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColors.textPrimary);
  });

  testWidgets('applies custom style', (tester) async {
    await tester.pumpWidget(
        wrap(const AppText('Hi', style: AppTypography.headingLg)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.fontSize, AppTypography.headingLg.fontSize);
  });

  testWidgets('applies custom color via copyWith', (tester) async {
    await tester.pumpWidget(
        wrap(const AppText('Hi', color: AppColors.textSecondary)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColors.textSecondary);
  });

  testWidgets('reflects textAlign', (tester) async {
    await tester.pumpWidget(
        wrap(const AppText('Hi', textAlign: TextAlign.center)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.textAlign, TextAlign.center);
  });

  testWidgets('reflects maxLines', (tester) async {
    await tester.pumpWidget(wrap(const AppText('Hi', maxLines: 3)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.maxLines, 3);
  });

  testWidgets('reflects overflow', (tester) async {
    await tester.pumpWidget(
        wrap(const AppText('Hi', overflow: TextOverflow.ellipsis)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('reflects semanticsLabel', (tester) async {
    await tester.pumpWidget(
        wrap(const AppText('Hi', semanticsLabel: 'greeting')));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.semanticsLabel, 'greeting');
  });
}
