import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Text content ───────────────────────────────────────────────────────────

  testWidgets('label text is shown', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    expect(find.text('Study'), findsOneWidget);
  });

  testWidgets('value text is shown', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    expect(find.text('CT-001'), findsOneWidget);
  });

  // ── Colors ─────────────────────────────────────────────────────────────────

  testWidgets('label uses textSecondary color', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    final text = tester.widget<Text>(find.text('Study'));
    expect(text.style?.color, AppColors.textSecondary);
  });

  testWidgets('value uses textPrimary color', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    final text = tester.widget<Text>(find.text('CT-001'));
    expect(text.style?.color, AppColors.textPrimary);
  });

  // ── Typography ─────────────────────────────────────────────────────────────

  testWidgets('label uses labelMd font size', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    final text = tester.widget<Text>(find.text('Study'));
    expect(text.style?.fontSize, AppTypography.labelMd.fontSize);
  });

  // ── Alignment ──────────────────────────────────────────────────────────────

  testWidgets('value is end-aligned', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Study', value: 'CT-001')));
    final text = tester.widget<Text>(find.text('CT-001'));
    expect(text.textAlign, TextAlign.end);
  });

  // ── valueKind (DL §4.2, §4.6) ──────────────────────────────────────────────

  const uid = '1.2.840.10008.5.1.4.1.1.2';

  testWidgets('text (default): clamps to one line', (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(label: 'Role', value: 'Radiologist')));
    final text = tester.widget<Text>(find.text('Radiologist'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.style?.fontFamily, AppTypography.bodyMd.fontFamily);
  });

  testWidgets('identifier: renders in the mono voice and never truncates',
      (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(
      label: 'Study UID',
      value: uid,
      valueKind: MetadataValueKind.identifier,
    )));
    final text = tester.widget<Text>(find.text(uid));
    expect(text.style?.fontFamily, AppTypography.mono.fontFamily);
    expect(text.maxLines, isNull);
    expect(text.overflow, isNull);
  });

  testWidgets('numeric: renders in the numeric voice and never truncates',
      (tester) async {
    await tester.pumpWidget(wrap(const MetadataField(
      label: 'Date',
      value: '2026-05-01',
      valueKind: MetadataValueKind.numeric,
    )));
    final text = tester.widget<Text>(find.text('2026-05-01'));
    expect(text.style?.fontFamily, AppTypography.numeric.fontFamily);
    expect(text.maxLines, isNull);
    expect(text.overflow, isNull);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
          body: MetadataField(label: 'Study', value: 'CT-001')),
    ));
    final label = tester.widget<Text>(find.text('Study'));
    expect(label.style?.color, AppColorsData.dark.textSecondary);
    final value = tester.widget<Text>(find.text('CT-001'));
    expect(value.style?.color, AppColorsData.dark.textPrimary);
  });
}
