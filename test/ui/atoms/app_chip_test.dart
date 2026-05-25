import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_chip.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

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
}
