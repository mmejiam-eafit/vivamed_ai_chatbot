import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/chat_bubble.dart';

void _suppressNetworkImageErrors() {
  final orig = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is NetworkImageLoadException) return;
    orig?.call(details);
  };
  addTearDown(() => FlutterError.onError = orig);
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  Container findBubble(WidgetTester tester, {required bool isUser}) {
    return tester.widget<Container>(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                (isUser ? ChatTokens.userBubble : ChatTokens.assistantBubble),
        description: 'bubble container',
      ),
    );
  }

  // ── Message text ───────────────────────────────────────────────────────────

  testWidgets('message text is shown', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hello', isUser: true)));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('message text uses bodyLg', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hello', isUser: true)));
    final text = tester.widget<Text>(find.text('Hello'));
    expect(text.style?.fontSize, AppTypography.bodyLg.fontSize);
  });

  // ── Width cap reads the box, not the window (DT §9.6) ─────────────────────

  testWidgets('caps width against its own box, not MediaQuery', (tester) async {
    await tester.pumpWidget(wrap(
      const SizedBox(
        width: 200,
        child: ChatBubble(message: 'Hello', isUser: true),
      ),
    ));
    final container = tester.widget<Container>(
      find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth != null,
        description: 'bubble container',
      ),
    );
    expect(container.constraints!.maxWidth, 200 * ChatTokens.bubbleMaxWidthFraction);
  });

  // ── Alignment ──────────────────────────────────────────────────────────────

  testWidgets('user bubble aligns right', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final aligns = tester.widgetList<Align>(find.byType(Align));
    expect(aligns.any((a) => a.alignment == Alignment.centerRight), isTrue);
  });

  testWidgets('assistant bubble aligns left', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final aligns = tester.widgetList<Align>(find.byType(Align));
    expect(aligns.any((a) => a.alignment == Alignment.centerLeft), isTrue);
  });

  // ── Background color ───────────────────────────────────────────────────────

  testWidgets('user bubble uses userBubble color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final dec = findBubble(tester, isUser: true).decoration! as BoxDecoration;
    expect(dec.color, ChatTokens.userBubble);
  });

  testWidgets('assistant bubble uses assistantBubble color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final dec = findBubble(tester, isUser: false).decoration! as BoxDecoration;
    expect(dec.color, ChatTokens.assistantBubble);
  });

  // ── Text color ─────────────────────────────────────────────────────────────

  testWidgets('user bubble uses userBubbleText color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, ChatTokens.userBubbleText);
  });

  testWidgets('assistant bubble uses assistantBubbleText color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, ChatTokens.assistantBubbleText);
  });

  // ── Border radius ──────────────────────────────────────────────────────────

  testWidgets('user bubble uses bubbleRadiusUser', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final dec = findBubble(tester, isUser: true).decoration! as BoxDecoration;
    expect(dec.borderRadius, ChatTokens.bubbleRadiusUser);
  });

  testWidgets('assistant bubble uses bubbleRadiusAssistant', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final dec = findBubble(tester, isUser: false).decoration! as BoxDecoration;
    expect(dec.borderRadius, ChatTokens.bubbleRadiusAssistant);
  });

  // ── Border ─────────────────────────────────────────────────────────────────

  testWidgets('assistant bubble has border', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final dec = findBubble(tester, isUser: false).decoration! as BoxDecoration;
    expect(dec.border, isNotNull);
  });

  testWidgets('user bubble has no border', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final dec = findBubble(tester, isUser: true).decoration! as BoxDecoration;
    expect(dec.border, isNull);
  });

  // ── Timestamp ──────────────────────────────────────────────────────────────

  testWidgets('timestamp is shown when provided', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(
      message: 'Hi',
      isUser: true,
      timestamp: '10:30',
    )));
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('timestamp is not shown when null', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    expect(find.text('10:30'), findsNothing);
  });

  // ── Avatar ─────────────────────────────────────────────────────────────────

  testWidgets('avatarInitials: renders AppAvatar', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(
      message: 'Hi',
      isUser: false,
      avatarInitials: 'AB',
    )));
    expect(find.byType(AppAvatar), findsOneWidget);
  });

  testWidgets('avatarImageUrl: renders AppAvatar', (tester) async {
    _suppressNetworkImageErrors();
    await tester.pumpWidget(wrap(const ChatBubble(
      message: 'Hi',
      isUser: true,
      avatarImageUrl: 'https://example.com/avatar.jpg',
    )));
    expect(find.byType(AppAvatar), findsOneWidget);
  });

  testWidgets('no avatar when neither imageUrl nor initials provided', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    expect(find.byType(AppAvatar), findsNothing);
  });
}
