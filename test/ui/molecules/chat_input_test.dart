import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/chat_input.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders TextField', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('renders send icon button', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  // ── Attach button ──────────────────────────────────────────────────────────

  testWidgets('no attach button when onAttach is null', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    expect(find.byIcon(Icons.attach_file), findsNothing);
  });

  testWidgets('attach button shown when onAttach provided', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      onAttach: () {},
    )));
    expect(find.byIcon(Icons.attach_file), findsOneWidget);
  });

  testWidgets('onAttach fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      onAttach: () => called = true,
    )));
    await tester.tap(find.byIcon(Icons.attach_file));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── onSubmit ───────────────────────────────────────────────────────────────

  testWidgets('onSubmit fires when send button tapped', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () => called = true,
    )));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── isLoading ──────────────────────────────────────────────────────────────

  testWidgets('isLoading: spinner shown and send icon hidden', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      isLoading: true,
    )));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.send), findsNothing);
  });

  // ── hintText ───────────────────────────────────────────────────────────────

  testWidgets('hintText is shown in TextField', (tester) async {
    await tester.pumpWidget(wrap(ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      hintText: 'Type something…',
    )));
    expect(find.text('Type something…'), findsOneWidget);
  });

  // ── controller ─────────────────────────────────────────────────────────────

  testWidgets('controller text is reflected', (tester) async {
    final controller = TextEditingController(text: 'draft');
    await tester.pumpWidget(wrap(ChatInput(
      controller: controller,
      onSubmit: () {},
    )));
    expect(find.text('draft'), findsOneWidget);
  });
}
