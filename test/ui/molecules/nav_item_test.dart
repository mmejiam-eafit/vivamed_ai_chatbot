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

  // Every real caller (ConversationDrawer, MenuRail, PrimaryNavDrawer) passes
  // its own background-tuned colors -- NavItem has no default left to fall
  // back to, so tests that aren't about color specifically just need some
  // distinguishable pair.
  const selected = Color(0xFF654321);
  const unselected = Color(0xFF123456);

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('icon is shown', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    expect(find.text('Home'), findsOneWidget);
  });

  // ── Color ──────────────────────────────────────────────────────────────────
  // No more shared default to override -- selectedColor/unselectedColor are
  // the only way a color is ever applied, so these are the whole contract.

  testWidgets('unselectedColor sets the icon, label, and hover color',
      (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, unselected);
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, unselected);
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      unselected.withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets(
      'selectedColor sets the icon, label, and hover color when isSelected',
      (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      isSelected: true,
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, selected);
    expect(icon.color, isNot(unselected));
    final text = tester.widget<Text>(find.text('Home'));
    expect(text.style?.color, selected);
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      selected.withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  // ── Touch target (DL §8.5, gap 14) ────────────────────────────────────────

  testWidgets('vertical layout meets the 44px floor', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    final size = tester.getSize(find.byType(FocusRing));
    expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
  });

  testWidgets('horizontal layout meets the 44px floor', (tester) async {
    await tester.pumpWidget(wrap(const NavItem(
      icon: Icons.home,
      label: 'Home',
      layout: NavItemLayout.horizontal,
      selectedColor: selected,
      unselectedColor: unselected,
    )));
    final size = tester.getSize(find.byType(FocusRing));
    expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
  });

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(NavItem(
      icon: Icons.home,
      label: 'Home',
      selectedColor: selected,
      unselectedColor: unselected,
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(
      NavItem(
        icon: Icons.home,
        label: 'Home',
        selectedColor: selected,
        unselectedColor: unselected,
        onTap: () {},
      ),
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
        selectedColor: selected,
        unselectedColor: unselected,
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
      NavItem(
        icon: Icons.home,
        label: 'Home',
        selectedColor: selected,
        unselectedColor: unselected,
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
          selectedColor: selected,
          unselectedColor: unselected,
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
}
