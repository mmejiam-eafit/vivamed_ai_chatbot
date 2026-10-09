import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/chat_input.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders the given messageList', (tester) async {
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const Text('the message list'),
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    expect(find.text('the message list'), findsOneWidget);
  });

  testWidgets('renders a ChatInput', (tester) async {
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const SizedBox(),
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('onSubmit fires when the send button is tapped', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const SizedBox(),
      controller: TextEditingController(),
      onSubmit: () => called = true,
    )));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('onAttach is passed through to ChatInput', (tester) async {
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const SizedBox(),
      controller: TextEditingController(),
      onSubmit: () {},
      onAttach: () {},
    )));
    expect(find.byIcon(Icons.attach_file), findsOneWidget);
  });

  testWidgets('isLoading is passed through to ChatInput', (tester) async {
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const SizedBox(),
      controller: TextEditingController(),
      onSubmit: () {},
      isLoading: true,
    )));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Divider ────────────────────────────────────────────────────────────────

  testWidgets('divider between the list and the composer uses borderSubdued',
      (tester) async {
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const SizedBox(),
      controller: TextEditingController(),
      onSubmit: () {},
    )));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColorsData.light.borderSubdued);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('divider resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: ChatPanel(
          messageList: const SizedBox(),
          controller: TextEditingController(),
          onSubmit: () {},
        ),
      ),
    ));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColorsData.dark.borderSubdued);
  });

  // ── Layout ─────────────────────────────────────────────────────────────────

  testWidgets('messageList fills the panel\'s width whatever it holds',
      (tester) async {
    // A bare ColoredBox takes the smallest size its constraints allow, so it
    // shows what the panel hands the slot (Text and ListView size themselves).
    await tester.pumpWidget(wrap(ChatPanel(
      messageList: const ColoredBox(key: Key('list'), color: Colors.red),
      controller: TextEditingController(),
      onSubmit: () {},
    )));

    final panel = tester.getSize(find.byType(ChatPanel));
    final input = tester.getSize(find.byType(ChatInput));
    // The divider is 1px; the list takes everything above it and the input.
    expect(
      tester.getSize(find.byKey(const Key('list'))),
      Size(panel.width, panel.height - 1 - input.height),
    );
  });
}
