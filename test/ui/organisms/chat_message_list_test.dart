import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/chat_bubble.dart';
import 'package:radiologist_helper/ui/molecules/typing_indicator.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const messages = [
    ChatMessageItem(message: 'Any consolidation?', isUser: true, timestamp: '09:14'),
    ChatMessageItem(message: 'Right lower lobe consolidation.', isUser: false),
  ];

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders one ChatBubble per message', (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(messages: messages)));
    expect(find.byType(ChatBubble), findsNWidgets(2));
  });

  testWidgets('renders the message text and timestamp', (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(messages: messages)));
    expect(find.text('Any consolidation?'), findsOneWidget);
    expect(find.text('09:14'), findsOneWidget);
  });

  testWidgets('empty, not typing: no bubbles and no exception', (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(messages: [])));
    expect(find.byType(ChatBubble), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // ── Typing indicator ───────────────────────────────────────────────────────

  testWidgets('isTyping: shows a TypingIndicator after the messages',
      (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(
      messages: messages,
      isTyping: true,
    )));
    await tester.pump();
    expect(find.byType(TypingIndicator), findsOneWidget);
  });

  testWidgets('isTyping: false shows no TypingIndicator', (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(messages: messages)));
    expect(find.byType(TypingIndicator), findsNothing);
  });

  testWidgets('the typing indicator aligns left, like an assistant message',
      (tester) async {
    await tester.pumpWidget(wrap(const ChatMessageList(
      messages: [],
      isTyping: true,
    )));
    await tester.pump();
    final align = tester.widget<Align>(find.ancestor(
      of: find.byType(TypingIndicator),
      matching: find.byType(Align),
    ));
    expect(align.alignment, Alignment.centerLeft);
  });
}
