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
}
