import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
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

  Container findBubble(
    WidgetTester tester, {
    required bool isUser,
    AppColorsData colors = AppColorsData.light,
  }) {
    return tester.widget<Container>(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                (isUser ? colors.interactivePrimary : colors.surface),
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
    expect(dec.color, AppColorsData.light.interactivePrimary);
  });

  testWidgets('assistant bubble uses assistantBubble color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final dec = findBubble(tester, isUser: false).decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.light.surface);
  });

  // ── Text color ─────────────────────────────────────────────────────────────

  testWidgets('user bubble uses userBubbleText color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: true)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColorsData.light.interactivePrimaryForeground);
  });

  testWidgets('assistant bubble uses assistantBubbleText color', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColorsData.light.textPrimary);
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

  // ── Case references (Chat → Study Review) ─────────────────────────────

  testWidgets('renders no chips when caseReferences is null', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(message: 'Hi', isUser: false)));
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });

  testWidgets('renders one chip per case reference', (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(
      message: 'I found 2 similar cases.',
      isUser: false,
      caseReferences: [
        CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
        CaseReference(caseId: 'case-3', title: 'Chest CT — Lung Nodule'),
      ],
    )));
    expect(find.byIcon(Icons.folder_outlined), findsNWidgets(2));
    expect(find.text('Abdominal CT'), findsOneWidget);
    expect(find.text('Chest CT — Lung Nodule'), findsOneWidget);
  });

  testWidgets('tapping a chip calls onCaseReferenceTap with its caseId',
      (tester) async {
    String? tapped;
    await tester.pumpWidget(wrap(ChatBubble(
      message: 'I found a similar case.',
      isUser: false,
      caseReferences: const [
        CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
      ],
      onCaseReferenceTap: (id) => tapped = id,
    )));
    await tester.tap(find.text('Abdominal CT'));
    await tester.pump();
    expect(tapped, 'case-2');
  });

  testWidgets('chip hovers with textPrimary at hoverOverlayOpacity',
      (tester) async {
    await tester.pumpWidget(wrap(const ChatBubble(
      message: 'I found a similar case.',
      isUser: false,
      caseReferences: [
        CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
      ],
    )));
    final inkWell = tester.widget<InkWell>(find.ancestor(
      of: find.text('Abdominal CT'),
      matching: find.byType(InkWell),
    ));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets('chip text resolves against the dark theme too', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: ChatBubble(
          message: 'I found a similar case.',
          isUser: false,
          caseReferences: [
            CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
          ],
        ),
      ),
    ));
    final title = tester.widget<Text>(find.text('Abdominal CT'));
    expect(title.style?.color, AppColorsData.dark.textOnAccent);
  });

  // ── Status ─────────────────────────────────────────────────────────────────

  group('status', () {
    Widget bubble(ChatMessageStatus? status, {Brightness? brightness}) =>
        MaterialApp(
          theme: buildAppTheme(brightness ?? Brightness.light),
          home: Scaffold(
            body: status == null
                ? const ChatBubble(message: 'Partial text', isUser: false)
                : ChatBubble(
                    message: 'Partial text',
                    isUser: false,
                    status: status,
                  ),
          ),
        );

    testWidgets('defaults to complete: no failure caption', (tester) async {
      await tester.pumpWidget(bubble(null));
      expect(find.text('Reply failed'), findsNothing);
      expect(find.text('Partial text'), findsOneWidget);
    });

    testWidgets('complete: no failure caption', (tester) async {
      await tester.pumpWidget(bubble(ChatMessageStatus.complete));
      expect(find.text('Reply failed'), findsNothing);
    });

    testWidgets('streaming: shows the text so far and no failure caption',
        (tester) async {
      await tester.pumpWidget(bubble(ChatMessageStatus.streaming));
      expect(find.text('Partial text'), findsOneWidget);
      expect(find.text('Reply failed'), findsNothing);
    });

    testWidgets('failed: keeps the partial text and adds a caption',
        (tester) async {
      await tester.pumpWidget(bubble(ChatMessageStatus.failed));
      expect(find.text('Partial text'), findsOneWidget);
      expect(find.text('Reply failed'), findsOneWidget);
    });

    testWidgets('failed: the caption sits below the bubble', (tester) async {
      await tester.pumpWidget(bubble(ChatMessageStatus.failed));
      expect(
        tester.getTopLeft(find.text('Reply failed')).dy,
        greaterThan(tester.getBottomLeft(find.text('Partial text')).dy),
      );
    });

    testWidgets('failed: the caption is caption-sized and statusError',
        (tester) async {
      await tester.pumpWidget(bubble(ChatMessageStatus.failed));
      final caption = tester.widget<Text>(find.text('Reply failed'));
      expect(caption.style?.fontSize, AppTypography.caption.fontSize);
      expect(caption.style?.color, AppColorsData.light.statusError);
    });

    testWidgets('failed: the caption resolves against the dark theme too',
        (tester) async {
      await tester.pumpWidget(
        bubble(ChatMessageStatus.failed, brightness: Brightness.dark),
      );
      final caption = tester.widget<Text>(find.text('Reply failed'));
      expect(caption.style?.color, AppColorsData.dark.statusError);
    });
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves bubble and text colors against the dark theme',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(body: ChatBubble(message: 'Hi', isUser: true)),
    ));
    final dec = findBubble(tester, isUser: true, colors: AppColorsData.dark)
        .decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.dark.interactivePrimary);
    final text = tester.widget<Text>(find.text('Hi'));
    expect(text.style?.color, AppColorsData.dark.interactivePrimaryForeground);
  });
}
