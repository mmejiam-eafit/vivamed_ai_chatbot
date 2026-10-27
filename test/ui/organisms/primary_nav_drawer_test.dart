import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders Home, Chat, Studies, Review, and Settings labels',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Studies'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('every destination renders as a horizontal-layout NavItem',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    final items = tester.widgetList<NavItem>(find.byType(NavItem));
    expect(items.length, 5);
    expect(items.every((i) => i.layout == NavItemLayout.horizontal), isTrue);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('selectedIndex null: nothing is selected', (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    final items = tester.widgetList<NavItem>(find.byType(NavItem));
    expect(items.any((i) => i.isSelected), isFalse);
  });

  testWidgets('selectedIndex 2: only Studies is selected', (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
    )));
    final items = tester.widgetList<NavItem>(find.byType(NavItem));
    expect(items.where((i) => i.isSelected).single.label, 'Studies');
  });

  // ── onDestinationSelected ──────────────────────────────────────────────────

  testWidgets('tapping Home calls onDestinationSelected with 0',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: 1,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('tapping Review calls onDestinationSelected with 3',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
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
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
    )));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(tapped, 4);
  });

  // ── Color: on-brand, not AppNavBar's default ──────────────────────────────
  // This drawer's background is surfaceBrandSecondary -- the same reason
  // ConversationDrawer's own Settings entry needed the on-brand override.

  testWidgets('unselected icon uses iconOnBrand, not the bottomNav default',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline));
    expect(icon.color, AppColorsData.light.iconOnBrand);
    expect(icon.color, isNot(AppColorsData.light.textMuted));
  });

  testWidgets('unselected icon color resolves against the dark theme too',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: PrimaryNavDrawer(
          selectedIndex: null,
          onDestinationSelected: (_) {},
        ),
      ),
    ));
    final icon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline));
    expect(icon.color, AppColorsData.dark.iconOnBrand);
    expect(icon.color, isNot(AppColorsData.dark.textMuted));
  });

  // The selected item used to fall through to NavItem's removed
  // NavigationTokens.bottomNavSelected default -- invisible only because it
  // numerically coincides with sideNavSelected/interactivePrimary in both
  // themes today, which is exactly why neither test below could distinguish
  // "the right token" from "a coincidentally-equal one" by value alone. They
  // pin the semantically correct value regardless, so a future divergence
  // between the bottom-nav and side-nav pairs is caught here, not shipped.

  testWidgets('selected icon uses NavigationTokens.sideNavSelected',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline));
    expect(icon.color, AppColorsData.light.interactivePrimary);
  });

  testWidgets('selected icon color resolves against the dark theme too',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: PrimaryNavDrawer(
          selectedIndex: 1,
          onDestinationSelected: (_) {},
        ),
      ),
    ));
    final icon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline));
    expect(icon.color, AppColorsData.dark.interactivePrimary);
  });

  // ── Width and background ───────────────────────────────────────────────────

  testWidgets('width reads NavigationTokens.sideNavWidth, not a literal',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    final drawer = tester.widget<Drawer>(find.byType(Drawer));
    expect(drawer.width, NavigationTokens.sideNavWidth);
  });

  testWidgets('background uses NavigationTokens.drawerBackground',
      (tester) async {
    await tester.pumpWidget(wrap(PrimaryNavDrawer(
      selectedIndex: null,
      onDestinationSelected: (_) {},
    )));
    final drawer = tester.widget<Drawer>(find.byType(Drawer));
    expect(drawer.backgroundColor, AppColorsData.light.surfaceBrandSecondary);
  });
}
