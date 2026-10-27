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

  testWidgets('renders Home, Chat, Studies, Review, and Settings labels',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    )));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Studies'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // ── Selected destination ───────────────────────────────────────────────────

  testWidgets('selectedIndex 0 shows the filled home icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);
  });

  testWidgets('selectedIndex 1 shows the filled chat icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
  });

  testWidgets('selectedIndex 2 shows the filled folder icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });

  testWidgets('selectedIndex 3 shows the filled flag icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 3,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
  });

  testWidgets('selectedIndex 4 shows the filled settings icon',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 4,
      onDestinationSelected: (_) {},
    )));
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
  });

  // ── onDestinationSelected ──────────────────────────────────────────────────

  testWidgets('tapping Home calls onDestinationSelected with 0',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('tapping Studies calls onDestinationSelected with 2',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Studies'));
    await tester.pump();
    expect(tapped, 2);
  });

  testWidgets('tapping Review calls onDestinationSelected with 3',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Review'));
    await tester.pump();
    expect(tapped, 3);
  });

  testWidgets('tapping Settings calls onDestinationSelected with 4',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(tapped, 4);
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
        body: AppNavBar(selectedIndex: 4, onDestinationSelected: (_) {}),
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
