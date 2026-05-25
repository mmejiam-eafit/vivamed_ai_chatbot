import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('icon is shown', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(icon: Icons.home, label: 'Home')));
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(icon: Icons.home, label: 'Home')));
    expect(find.text('Home'), findsOneWidget);
  });

  // ── Icon color ─────────────────────────────────────────────────────────────

  testWidgets('unselected: icon uses bottomNavUnselected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: false,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, NavigationTokens.bottomNavUnselected);
  });

  testWidgets('selected: icon uses bottomNavSelected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, NavigationTokens.bottomNavSelected);
  });

  // ── Label color ────────────────────────────────────────────────────────────

  testWidgets('unselected: label uses bottomNavUnselected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: false,
    )));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, NavigationTokens.bottomNavUnselected);
  });

  testWidgets('selected: label uses bottomNavSelected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
    )));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, NavigationTokens.bottomNavSelected);
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(NavItem(
      icon: Icons.home,
      label: 'Home',
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(called, isTrue);
  });
}
