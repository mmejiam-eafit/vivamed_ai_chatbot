import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders the Menu label and icon', (tester) async {
    await tester.pumpWidget(wrap(MenuRail(onMenuTap: () {})));
    expect(find.text('Menu'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  // ── onMenuTap ──────────────────────────────────────────────────────────────

  testWidgets('tapping fires onMenuTap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(MenuRail(onMenuTap: () => called = true)));
    await tester.tap(find.text('Menu'));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Width and background ───────────────────────────────────────────────────

  testWidgets('width reads NavigationTokens.sideNavCollapsedWidth, not a literal',
      (tester) async {
    await tester.pumpWidget(wrap(MenuRail(onMenuTap: () {})));
    expect(
      tester.getSize(find.byType(MenuRail)).width,
      NavigationTokens.sideNavCollapsedWidth,
    );
  });

  testWidgets('background uses NavigationTokens.sideNavBackground',
      (tester) async {
    await tester.pumpWidget(wrap(MenuRail(onMenuTap: () {})));
    final container = tester.widget<Container>(find.byType(Container).first);
    expect(container.color, AppColorsData.light.surfaceBrandSecondary);
  });

  // ── Color: on-brand, not the bottomNav default ─────────────────────────────

  testWidgets('icon uses iconOnBrand, not the bottomNav default', (tester) async {
    await tester.pumpWidget(wrap(MenuRail(onMenuTap: () {})));
    final icon = tester.widget<Icon>(find.byIcon(Icons.menu));
    expect(icon.color, AppColorsData.light.iconOnBrand);
    expect(icon.color, isNot(AppColorsData.light.textMuted));
  });

  testWidgets('icon color resolves against the dark theme too', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(body: MenuRail(onMenuTap: () {})),
    ));
    final icon = tester.widget<Icon>(find.byIcon(Icons.menu));
    expect(icon.color, AppColorsData.dark.iconOnBrand);
    expect(icon.color, isNot(AppColorsData.dark.textMuted));
  });
}
