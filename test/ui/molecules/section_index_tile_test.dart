import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/section_index_tile.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  testWidgets('renders the title', (tester) async {
    await tester.pumpWidget(wrap(
      SectionIndexTile(title: 'Account', isSelected: false, onTap: () {}),
    ));
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('unselected: no fill, textPrimary label', (tester) async {
    await tester.pumpWidget(wrap(
      SectionIndexTile(title: 'Account', isSelected: false, onTap: () {}),
    ));
    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.selected, isFalse);
    final text = tester.widget<Text>(find.text('Account'));
    expect(text.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('selected: surfaceSubdued fill, interactivePrimary label',
      (tester) async {
    await tester.pumpWidget(wrap(
      SectionIndexTile(title: 'Account', isSelected: true, onTap: () {}),
    ));
    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.selected, isTrue);
    expect(tile.selectedTileColor, AppColorsData.light.surfaceSubdued);
    final text = tester.widget<Text>(find.text('Account'));
    expect(text.style?.color, AppColorsData.light.interactivePrimary);
  });

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(
      SectionIndexTile(
        title: 'Account',
        isSelected: false,
        onTap: () => called = true,
      ),
    ));
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('a null onTap does not throw when tapped', (tester) async {
    await tester.pumpWidget(wrap(
      const SectionIndexTile(title: 'Account', isSelected: false, onTap: null),
    ));
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      SectionIndexTile(title: 'Account', isSelected: true, onTap: () {}),
      brightness: Brightness.dark,
    ));
    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.selectedTileColor, AppColorsData.dark.surfaceSubdued);
    final text = tester.widget<Text>(find.text('Account'));
    expect(text.style?.color, AppColorsData.dark.interactivePrimary);
  });
}
