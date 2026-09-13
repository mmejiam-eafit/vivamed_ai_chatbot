import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/case_reference_chip.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders the title', (tester) async {
    await tester.pumpWidget(wrap(CaseReferenceChip(
      title: 'Abdominal CT',
      onTap: () {},
    )));
    expect(find.text('Abdominal CT'), findsOneWidget);
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(CaseReferenceChip(
      title: 'Abdominal CT',
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(CaseReferenceChip(
      title: 'Abdominal CT',
      onTap: () {},
      focusNode: focusNode,
    )));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ).first);
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.light.borderFocused);
  });

  // ── Hover ────────────────────────────────────────────────────────────────

  testWidgets('hover tints textPrimary at hoverOverlayOpacity', (tester) async {
    await tester.pumpWidget(wrap(CaseReferenceChip(
      title: 'Abdominal CT',
      onTap: () {},
    )));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  // ── Dark theme ─────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      CaseReferenceChip(title: 'Abdominal CT', onTap: () {}),
      brightness: Brightness.dark,
    ));
    final title = tester.widget<Text>(find.text('Abdominal CT'));
    expect(title.style?.color, AppColorsData.dark.textOnAccent);
  });
}
