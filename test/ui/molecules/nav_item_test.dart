import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
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
    expect(icon.color, AppColorsData.light.textMuted);
  });

  testWidgets('selected: icon uses bottomNavSelected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, AppColorsData.light.iconAccent);
  });

  // ── Label color ────────────────────────────────────────────────────────────

  testWidgets('unselected: label uses bottomNavUnselected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: false,
    )));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, AppColorsData.light.textMuted);
  });

  testWidgets('selected: label uses bottomNavSelected color', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
    )));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, AppColorsData.light.iconAccent);
  });

  // ── Color overrides ────────────────────────────────────────────────────────

  testWidgets('unselectedColor overrides the bottomNavUnselected default',
      (tester) async {
    const override = Color(0xFF123456);
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      unselectedColor: override,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, override);
    expect(icon.color, isNot(AppColorsData.light.textMuted));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, override);
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      override.withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets('selectedColor overrides the bottomNavSelected default',
      (tester) async {
    const override = Color(0xFF654321);
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
      selectedColor: override,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, override);
    expect(icon.color, isNot(AppColorsData.light.iconAccent));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, override);
  });

  testWidgets('with no override, behavior is unchanged from bottomNav* defaults',
      (tester) async {
    await tester.pumpWidget(wrap(const NavItem(icon: Icons.home, label: 'Home')));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, AppColorsData.light.textMuted);
  });

  // ── Hover (gap 23) ─────────────────────────────────────────────────────────

  testWidgets('unselected: hover tints textMuted at hoverOverlayOpacity',
      (tester) async {
    await tester.pumpWidget(wrap(const NavItem(icon: Icons.home, label: 'Home')));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.textMuted
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets('selected: hover tints iconAccent at hoverOverlayOpacity',
      (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
    )));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.iconAccent
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets('hover color resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: NavItem(icon: Icons.home, label: 'Home'),
      ),
    ));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.dark.textMuted
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  // ── Touch target (DL §8.5, gap 14) ────────────────────────────────────────

  testWidgets('vertical layout meets the 44px floor', (tester) async {
    await tester.pumpWidget(wrap(
      const NavItem(icon: Icons.home, label: 'Home'),
    ));
    final size = tester.getSize(find.byType(FocusRing));
    expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
  });

  testWidgets('horizontal layout meets the 44px floor', (tester) async {
    await tester.pumpWidget(wrap(
      const NavItem(
        icon: Icons.home,
        label: 'Home',
        layout: NavItemLayout.horizontal,
      ),
    ));
    final size = tester.getSize(find.byType(FocusRing));
    expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
  });

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

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(
      NavItem(icon: Icons.home, label: 'Home', onTap: () {}),
    ));
    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(
      NavItem(
        icon: Icons.home,
        label: 'Home',
        onTap: () {},
        focusNode: focusNode,
      ),
    ));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.light.borderFocused);
  });

  testWidgets('with no onTap, requesting focus does not show a ring',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(
      NavItem(icon: Icons.home, label: 'Home', focusNode: focusNode),
    ));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('focus ring resolves against the dark theme', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: NavItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {},
          focusNode: focusNode,
        ),
      ),
    ));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.dark.borderFocused);
  });

  testWidgets('selected icon/label resolve against the dark theme',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: NavItem(icon: Icons.home, label: 'Home', isSelected: true),
      ),
    ));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, AppColorsData.dark.iconAccent);
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, AppColorsData.dark.iconAccent);
  });
}
