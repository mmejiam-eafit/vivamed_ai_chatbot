import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/typing_indicator.dart';

// TypingIndicator uses an AnimationController.repeat().
// Do NOT use pumpAndSettle — it will time out on a repeating animation.
// Use pump() to advance a single frame.

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  final dotFinder = find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle,
    description: 'animated dot',
  );

  testWidgets('renders without throwing', (tester) async {
    await tester.pumpWidget(wrap(const TypingIndicator()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders 3 animated dots', (tester) async {
    await tester.pumpWidget(wrap(const TypingIndicator()));
    await tester.pump();
    expect(dotFinder, findsNWidgets(3));
  });

  testWidgets('dots use typingIndicator color', (tester) async {
    await tester.pumpWidget(wrap(const TypingIndicator()));
    await tester.pump();
    final dot = tester.firstWidget<Container>(dotFinder);
    expect(
      (dot.decoration! as BoxDecoration).color,
      AppColorsData.light.interactiveAccent,
    );
  });

  testWidgets('uses assistantBubbleRadiusAssistant border radius', (tester) async {
    await tester.pumpWidget(wrap(const TypingIndicator()));
    await tester.pump();
    tester.widget<Container>(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius ==
                ChatTokens.bubbleRadiusAssistant,
        description: 'assistant bubble container',
      ),
    );
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('dots resolve typingIndicator color against the dark theme',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(body: TypingIndicator()),
    ));
    await tester.pump();
    final dot = tester.firstWidget<Container>(dotFinder);
    expect(
      (dot.decoration! as BoxDecoration).color,
      AppColorsData.dark.interactiveAccent,
    );
  });
}
