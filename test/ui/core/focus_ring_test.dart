import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  BoxDecoration ringDecoration(WidgetTester tester) =>
      tester.widget<Container>(find.byType(Container)).decoration!
          as BoxDecoration;

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(wrap(FocusRing(
      borderRadius: AppRadius.borderButton,
      child: const Text('content'),
    )));
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('applies the given borderRadius', (tester) async {
    await tester.pumpWidget(wrap(FocusRing(
      borderRadius: AppRadius.borderPanel,
      child: const SizedBox(),
    )));
    expect(ringDecoration(tester).borderRadius, AppRadius.borderPanel);
  });

  testWidgets('transparent border when nothing inside can hold focus',
      (tester) async {
    await tester.pumpWidget(wrap(FocusRing(
      borderRadius: AppRadius.borderButton,
      // Text has no Focus node of its own — nothing here can ever focus.
      child: const Text('inert'),
    )));
    expect(ringDecoration(tester).border!.top.color, Colors.transparent);
  });

  testWidgets('shows the border when a focusable descendant is focused',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(FocusRing(
      borderRadius: AppRadius.borderButton,
      child: Focus(focusNode: focusNode, child: const Text('focusable')),
    )));
    focusNode.requestFocus();
    await tester.pump();
    expect(ringDecoration(tester).border!.top.color,
        AppColorsData.light.borderFocused);
  });

  testWidgets('this ring never requests focus itself', (tester) async {
    await tester.pumpWidget(wrap(FocusRing(
      borderRadius: AppRadius.borderButton,
      child: const Text('content'),
    )));
    // MaterialApp's own ancestor chain has several unrelated Focus widgets
    // (traversal groups, shortcuts) — scope to FocusRing's own subtree.
    final ownFocus = tester.widget<Focus>(find
        .descendant(of: find.byType(FocusRing), matching: find.byType(Focus))
        .first);
    expect(ownFocus.canRequestFocus, isFalse);
  });
}
