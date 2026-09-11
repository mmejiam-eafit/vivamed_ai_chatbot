import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/theme_mode_selector.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  testWidgets('renders all three rows', (tester) async {
    await tester.pumpWidget(wrap(
      ThemeModeSelector(selected: ThemeMode.dark, onChanged: (_) {}),
    ));
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('shows a checkmark only on the selected row', (tester) async {
    await tester.pumpWidget(wrap(
      ThemeModeSelector(selected: ThemeMode.light, onChanged: (_) {}),
    ));
    expect(find.byIcon(Icons.check), findsOneWidget);

    final light = tester.widget<Text>(find.text('Light'));
    expect(light.style?.color, AppColorsData.light.interactivePrimary);
    final dark = tester.widget<Text>(find.text('Dark'));
    expect(dark.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('tapping Dark fires onChanged with ThemeMode.dark',
      (tester) async {
    ThemeMode? picked;
    await tester.pumpWidget(wrap(
      ThemeModeSelector(
        selected: ThemeMode.light,
        onChanged: (m) => picked = m,
      ),
    ));
    await tester.tap(find.text('Dark'));
    await tester.pump();
    expect(picked, ThemeMode.dark);
  });

  testWidgets('tapping System fires onChanged with ThemeMode.system',
      (tester) async {
    ThemeMode? picked;
    await tester.pumpWidget(wrap(
      ThemeModeSelector(
        selected: ThemeMode.dark,
        onChanged: (m) => picked = m,
      ),
    ));
    await tester.tap(find.text('System'));
    await tester.pump();
    expect(picked, ThemeMode.system);
  });

  testWidgets('every row hovers with textPrimary at hoverOverlayOpacity',
      (tester) async {
    await tester.pumpWidget(wrap(
      ThemeModeSelector(selected: ThemeMode.dark, onChanged: (_) {}),
    ));
    final expected = AppColorsData.light.textPrimary
        .withValues(alpha: AppInteraction.hoverOverlayOpacity);
    for (final tile in tester.widgetList<ListTile>(find.byType(ListTile))) {
      expect(tile.hoverColor, expected);
    }
  });

  testWidgets('hover color resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      ThemeModeSelector(selected: ThemeMode.dark, onChanged: (_) {}),
      brightness: Brightness.dark,
    ));
    final expected = AppColorsData.dark.textPrimary
        .withValues(alpha: AppInteraction.hoverOverlayOpacity);
    for (final tile in tester.widgetList<ListTile>(find.byType(ListTile))) {
      expect(tile.hoverColor, expected);
    }
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      ThemeModeSelector(selected: ThemeMode.dark, onChanged: (_) {}),
      brightness: Brightness.dark,
    ));
    final dark = tester.widget<Text>(find.text('Dark'));
    expect(dark.style?.color, AppColorsData.dark.interactivePrimary);
  });
}
