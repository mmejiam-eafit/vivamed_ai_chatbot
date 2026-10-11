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
    ChatMessageItem(id: 'm1', message: 'Any consolidation?', isUser: true, timestamp: '09:14'),
    ChatMessageItem(id: 'm2', message: 'Right lower lobe consolidation.', isUser: false),
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

  // ── Case references (threads onCaseReferenceTap through) ─────────────────

  testWidgets('tapping a referenced case calls onCaseReferenceTap', (tester) async {
    String? tapped;
    await tester.pumpWidget(wrap(ChatMessageList(
      messages: const [
        ChatMessageItem(
          id: 'm3',
          message: 'I found a similar case.',
          isUser: false,
          caseReferences: [
            CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
          ],
        ),
      ],
      onCaseReferenceTap: (id) => tapped = id,
    )));

    await tester.tap(find.text('Abdominal CT'));
    await tester.pump();

    expect(tapped, 'case-2');
  });

  // ── Streaming status ───────────────────────────────────────────────────────

  group('reply status', () {
    ChatMessageItem reply(String text, ChatMessageStatus status) =>
        ChatMessageItem(id: 'r', message: text, isUser: false, status: status);

    testWidgets(
        'streaming with no text yet: the typing indicator stands in for a bubble',
        (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [...messages, reply('', ChatMessageStatus.streaming)],
      )));
      await tester.pump();

      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(find.byType(ChatBubble), findsNWidgets(messages.length));
    });

    testWidgets('streaming with text: its bubble, and no indicator',
        (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [...messages, reply('No eff', ChatMessageStatus.streaming)],
      )));

      expect(find.text('No eff'), findsOneWidget);
      expect(find.byType(ChatBubble), findsNWidgets(messages.length + 1));
      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('streaming with no text yet is left-aligned, like a reply',
        (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [reply('', ChatMessageStatus.streaming)],
      )));
      await tester.pump();

      final align = tester.widget<Align>(find.ancestor(
        of: find.byType(TypingIndicator),
        matching: find.byType(Align),
      ));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('failed: its bubble with the failure caption', (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [...messages, reply('No eff', ChatMessageStatus.failed)],
      )));

      expect(find.text('No eff'), findsOneWidget);
      expect(find.text('Reply failed'), findsOneWidget);
      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('failed with no text at all still shows the caption',
        (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [reply('', ChatMessageStatus.failed)],
      )));

      expect(find.text('Reply failed'), findsOneWidget);
      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('complete: no caption and no indicator', (tester) async {
      await tester.pumpWidget(wrap(ChatMessageList(
        messages: [...messages, reply('Done.', ChatMessageStatus.complete)],
      )));

      expect(find.text('Reply failed'), findsNothing);
      expect(find.byType(TypingIndicator), findsNothing);
    });
  });

  // ── Scrolling ──────────────────────────────────────────────────────────────

  group('scrolling', () {
    final longText = List.filled(80, 'Streaming text').join(' ');

    List<ChatMessageItem> thread(
      int count, {
      String? lastText,
      ChatMessageStatus lastStatus = ChatMessageStatus.complete,
    }) =>
        [
          for (var i = 0; i < count; i++)
            ChatMessageItem(
              id: 'm$i',
              message: i == count - 1 && lastText != null
                  ? lastText
                  : 'Message $i',
              isUser: i.isEven,
              status: i == count - 1 ? lastStatus : ChatMessageStatus.complete,
            ),
        ];

    ScrollPosition positionOf(WidgetTester tester) =>
        tester.state<ScrollableState>(find.byType(Scrollable)).position;

    Future<void> show(WidgetTester tester, List<ChatMessageItem> items) =>
        tester.pumpWidget(wrap(ChatMessageList(messages: items)));

    /// Long enough to scroll, then one more message so the list is pinned to
    /// its bottom -- where a reader following a live reply is.
    Future<void> pinnedAtBottom(WidgetTester tester) async {
      await show(tester, thread(30));
      await show(tester, thread(31));
      await tester.pumpAndSettle();
    }

    testWidgets('a new message animates the list to the bottom', (tester) async {
      await show(tester, thread(30));
      expect(positionOf(tester).pixels, 0);

      await show(tester, thread(31));
      await tester.pumpAndSettle();

      final position = positionOf(tester);
      expect(position.pixels, greaterThan(0));
      expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    });

    testWidgets('the typing indicator appearing scrolls it into view',
        (tester) async {
      await show(tester, thread(30));

      await tester.pumpWidget(
        wrap(ChatMessageList(messages: thread(30), isTyping: true)),
      );
      // pump, not pumpAndSettle: the indicator's dots animate forever.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // On screen, not merely built: a lazy list also builds a cache extent
      // beyond the viewport.
      expect(positionOf(tester).pixels, greaterThan(0));
      final indicator = tester.getRect(find.byType(TypingIndicator));
      final viewport = tester.getRect(find.byType(ListView));
      expect(indicator.bottom, lessThanOrEqualTo(viewport.bottom));
      expect(indicator.top, greaterThanOrEqualTo(viewport.top));
    });

    testWidgets('text growing in the last message follows while pinned',
        (tester) async {
      await pinnedAtBottom(tester);
      final extentBefore = positionOf(tester).maxScrollExtent;

      await show(
        tester,
        thread(31, lastText: longText, lastStatus: ChatMessageStatus.streaming),
      );
      await tester.pump();
      await tester.pump();

      final position = positionOf(tester);
      expect(position.maxScrollExtent, greaterThan(extentBefore));
      expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    });

    testWidgets('a status change that adds the caption follows while pinned',
        (tester) async {
      await pinnedAtBottom(tester);
      await show(
        tester,
        thread(31, lastText: longText, lastStatus: ChatMessageStatus.streaming),
      );
      await tester.pump();
      await tester.pump();
      final extentBefore = positionOf(tester).maxScrollExtent;

      await show(
        tester,
        thread(31, lastText: longText, lastStatus: ChatMessageStatus.failed),
      );
      await tester.pump();
      await tester.pump();

      final position = positionOf(tester);
      expect(position.maxScrollExtent, greaterThan(extentBefore));
      expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    });

    testWidgets('does not yank a reader who scrolled up', (tester) async {
      await pinnedAtBottom(tester);
      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pump();
      final scrolledUpTo = positionOf(tester).pixels;
      expect(
        positionOf(tester).maxScrollExtent - scrolledUpTo,
        greaterThan(AppSpacing.xxxl),
      );

      await show(
        tester,
        thread(31, lastText: longText, lastStatus: ChatMessageStatus.streaming),
      );
      await tester.pump();
      await tester.pump();

      expect(positionOf(tester).pixels, scrolledUpTo);
    });

    testWidgets('an update that changes nothing leaves the position alone',
        (tester) async {
      await pinnedAtBottom(tester);
      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pump();
      final scrolledUpTo = positionOf(tester).pixels;

      await show(tester, thread(31));
      await tester.pumpAndSettle();

      expect(positionOf(tester).pixels, scrolledUpTo);
    });

    testWidgets('a list that fits on screen simply follows, no exception',
        (tester) async {
      await show(tester, thread(1, lastText: 'Hi'));
      await show(
        tester,
        thread(1, lastText: 'Hi there', lastStatus: ChatMessageStatus.streaming),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
