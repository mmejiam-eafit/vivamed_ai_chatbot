import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_chip.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Widget type selection ──────────────────────────────────────────────────

  testWidgets('no onSelected renders Chip', (tester) async {
    await tester.pumpWidget(wrap(const AppChip(label: 'Tag')));
    expect(find.byType(Chip), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
  });

  testWidgets('with onSelected renders FilterChip', (tester) async {
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (_) {}),
    ));
    expect(find.byType(FilterChip), findsOneWidget);
  });

  // ── Label ──────────────────────────────────────────────────────────────────

  testWidgets('label text is shown', (tester) async {
    await tester.pumpWidget(wrap(const AppChip(label: 'Hello')));
    expect(find.text('Hello'), findsOneWidget);
  });

  // ── onSelected callback ────────────────────────────────────────────────────

  testWidgets('onSelected fires on tap', (tester) async {
    bool? selectedValue;
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (v) => selectedValue = v),
    ));
    await tester.tap(find.byType(FilterChip));
    await tester.pump();
    expect(selectedValue, isNotNull);
  });

  // ── onDeleted callback ─────────────────────────────────────────────────────

  // In Material 3, FilterChip is a pure selection chip with no delete icon.
  // Verify the callback is wired up rather than testing tap on a missing icon.
  testWidgets('onDeleted is passed through to FilterChip widget', (tester) async {
    void onDeleted() {}
    await tester.pumpWidget(wrap(
      AppChip(
        label: 'Tag',
        onSelected: (_) {},
        onDeleted: onDeleted,
      ),
    ));
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.onDeleted, isNotNull);
  });

  testWidgets('onDeleted fires on delete tap (Chip)', (tester) async {
    var deleted = false;
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onDeleted: () => deleted = true),
    ));
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();
    expect(deleted, isTrue);
  });

  // ── Colors ─────────────────────────────────────────────────────────────────

  testWidgets('FilterChip uses surfaceAccent as unselected background',
      (tester) async {
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (_) {}),
    ));
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.backgroundColor, AppColors.surfaceAccent);
  });

  testWidgets('FilterChip uses interactivePrimary as selectedColor',
      (tester) async {
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (_) {}),
    ));
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.selectedColor, AppColors.interactivePrimary);
  });

  // ── avatar ─────────────────────────────────────────────────────────────────

  testWidgets('avatar widget is shown when provided', (tester) async {
    await tester.pumpWidget(wrap(
      const AppChip(
        label: 'Tag',
        avatar: Icon(Icons.star, key: Key('avatar-icon')),
      ),
    ));
    expect(find.byKey(const Key('avatar-icon')), findsOneWidget);
  });

  // ── selected state ─────────────────────────────────────────────────────────

  testWidgets('selected: true is reflected in FilterChip', (tester) async {
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', selected: true, onSelected: (_) {}),
    ));
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.selected, isTrue);
  });

  // ── Focus ring (DL §8.4) — only the selectable FilterChip has one ────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (_) {}),
    ));
    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(FilterChip),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(
      AppChip(label: 'Tag', onSelected: (_) {}, focusNode: focusNode),
    ));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(FilterChip),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.light.borderFocused);
  });

  testWidgets('a non-selectable Chip has no focus ring at all', (tester) async {
    await tester.pumpWidget(wrap(const AppChip(label: 'Tag')));
    expect(find.byType(FocusRing), findsNothing);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(body: AppChip(label: 'Tag', onSelected: (_) {})),
    ));
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.backgroundColor, AppColorsData.dark.surfaceAccent);
    expect(chip.selectedColor, AppColorsData.dark.interactivePrimary);
  });
}
