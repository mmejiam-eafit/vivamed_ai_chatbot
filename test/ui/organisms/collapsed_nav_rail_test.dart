import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/collapsed_nav_rail.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  testWidgets('is sideNavCollapsedWidth wide', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}),
    ));
    final size = tester.getSize(find.byType(CollapsedNavRail));
    expect(size.width, NavigationTokens.sideNavCollapsedWidth);
  });

  testWidgets('renders the menu icon', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}),
    ));
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('onMenuTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () => called = true),
    ));
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('no findings icon when onFindingsTap is null', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}),
    ));
    expect(find.byIcon(Icons.assignment_outlined), findsNothing);
  });

  testWidgets('findings icon shown and fires onFindingsTap when provided',
      (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}, onFindingsTap: () => called = true),
    ));
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('both icons meet the 44px touch-target floor', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}, onFindingsTap: () {}),
    ));
    for (final icon in [Icons.menu, Icons.assignment_outlined]) {
      final size = tester.getSize(find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(ConstrainedBox),
      ).first);
      expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
      expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    }
  });

  testWidgets('both icons hover with sideNavHoverColor', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}, onFindingsTap: () {}),
    ));
    for (final inkWell in tester.widgetList<InkWell>(find.byType(InkWell))) {
      expect(inkWell.hoverColor, NavigationTokens.sideNavHoverColor);
    }
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      CollapsedNavRail(onMenuTap: () {}),
      brightness: Brightness.dark,
    ));
    // The rail's own background Container is the outermost -- first in
    // traversal order, ahead of FocusRing's internal ones per icon.
    final container = tester.widgetList<Container>(find.descendant(
      of: find.byType(CollapsedNavRail),
      matching: find.byType(Container),
    )).first;
    expect(container.color, AppColorsData.dark.surfaceBrandSecondary);
  });
}
