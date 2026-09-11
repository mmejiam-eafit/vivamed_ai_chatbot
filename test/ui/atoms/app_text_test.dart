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
    expect(text.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('applies custom style', (tester) async {
    await tester
        .pumpWidget(wrap(const AppText('Hi', style: AppTypography.headingLg)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.fontSize, AppTypography.headingLg.fontSize);
  });

  testWidgets('applies custom color via copyWith', (tester) async {
    await tester
        .pumpWidget(wrap(const AppText('Hi', color: AppColors.textSecondary)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColors.textSecondary);
  });

  testWidgets('reflects textAlign', (tester) async {
    await tester
        .pumpWidget(wrap(const AppText('Hi', textAlign: TextAlign.center)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.textAlign, TextAlign.center);
  });

  testWidgets('reflects maxLines', (tester) async {
    await tester.pumpWidget(wrap(const AppText('Hi', maxLines: 3)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.maxLines, 3);
  });

  testWidgets('reflects overflow', (tester) async {
    await tester
        .pumpWidget(wrap(const AppText('Hi', overflow: TextOverflow.ellipsis)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('reflects semanticsLabel', (tester) async {
    await tester
        .pumpWidget(wrap(const AppText('Hi', semanticsLabel: 'greeting')));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.semanticsLabel, 'greeting');
  });

  // ── role ──────────────────────────────────────────────────────────────────────────────

  const roleExpectations = {
    AppTextRole.primary: 'textPrimary',
    AppTextRole.secondary: 'textSecondary',
    AppTextRole.tertiary: 'textTertiary',
    AppTextRole.muted: 'textMuted',
    AppTextRole.onBrand: 'textOnBrand',
    AppTextRole.onAccent: 'textOnAccent',
    AppTextRole.disabled: 'textDisabled',
    AppTextRole.placeholder: 'textPlaceholder',
    AppTextRole.link: 'textLink',
    AppTextRole.linkVisited: 'textLinkVisited',
  };

  Color lightColorFor(String field) => switch (field) {
        'textPrimary' => AppColorsData.light.textPrimary,
        'textSecondary' => AppColorsData.light.textSecondary,
        'textTertiary' => AppColorsData.light.textTertiary,
        'textMuted' => AppColorsData.light.textMuted,
        'textOnBrand' => AppColorsData.light.textOnBrand,
        'textOnAccent' => AppColorsData.light.textOnAccent,
        'textDisabled' => AppColorsData.light.textDisabled,
        'textPlaceholder' => AppColorsData.light.textPlaceholder,
        'textLink' => AppColorsData.light.textLink,
        'textLinkVisited' => AppColorsData.light.textLinkVisited,
        _ => throw ArgumentError(field),
      };

  for (final entry in roleExpectations.entries) {
    testWidgets(
        'role.${entry.key.name} resolves to context.colors.${entry.value}',
        (tester) async {
      await tester.pumpWidget(wrap(AppText('Hi', role: entry.key)));
      final text = tester.widget<Text>(find.text('Hi'));
      expect(text.style?.color, lightColorFor(entry.value));
    });
  }

  testWidgets('explicit color wins over role', (tester) async {
    await tester.pumpWidget(wrap(const AppText(
      'Hi',
      role: AppTextRole.secondary,
      color: AppColors.statusError,
    )));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColors.statusError);
  });

  testWidgets('role resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(body: AppText('Hi', role: AppTextRole.primary)),
    ));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColorsData.dark.textPrimary);
  });
}
