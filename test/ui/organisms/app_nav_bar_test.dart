import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders Chat, Studies, and Settings labels', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    )));
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Studies'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // ── Selected destination ───────────────────────────────────────────────────

  testWidgets('selectedIndex 0 shows the filled chat icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
  });

  testWidgets('selectedIndex 1 shows the filled folder icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });

  // ── onDestinationSelected ──────────────────────────────────────────────────

  testWidgets('tapping Studies calls onDestinationSelected with 1', (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Studies'));
    await tester.pump();
    expect(tapped, 1);
  });

  // ── Background color ───────────────────────────────────────────────────────

  testWidgets('background uses NavigationTokens.bottomNavBackground',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    )));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.light.surface);
    expect(dec.border!.top.color, AppColorsData.light.borderSubdued);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: AppNavBar(selectedIndex: 2, onDestinationSelected: (_) {}),
      ),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.dark.surface);
    expect(dec.border!.top.color, AppColorsData.dark.borderSubdued);

    final icon = tester.widget<Icon>(find.byIcon(Icons.settings));
    expect(icon.color, AppColorsData.dark.iconAccent);
  });
}
