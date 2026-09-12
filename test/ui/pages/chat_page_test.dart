import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  group('ChatPage', () {
    testWidgets('renders ChatTemplate', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ChatTemplate), findsOneWidget);
    });

    testWidgets('renders Chat in app bar', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('app bar title renders in headingMd, not the platform default',
        (tester) async {
      // Regression guard for gap 11: AppBar titles used to fall back to
      // Flutter's own Roboto Typography because buildAppTheme() set no
      // titleTextStyle and no textTheme.
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final paragraph = tester.renderObject<RenderParagraph>(find.text('Chat'));
      expect(paragraph.text.style?.fontFamily, AppTypography.headingMd.fontFamily);
    });

    testWidgets('renders ChatPanel slot', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    testWidgets('renders FindingsPanel slot', (tester) async {
      // Pumped wide: at the default test size (800x600, medium tier),
      // findingsPanel is endDrawer content and isn't mounted until opened --
      // wide is where it renders inline and unconditionally.
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(FindingsPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: threePaneMinWidth - 1 (narrow) ────────────────

    testWidgets('narrow below threePaneMinWidth: drawer assigned to Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.threePaneMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    testWidgets('compact: findings rendered as bottom sheet', (tester) async {
      // Only compact (< mediumMinWidth) uses the bottom sheet now -- medium
      // and the rest of the pre-three-pane band use the collapsed rail's
      // endDrawer instead (gap 17).
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomSheet, isNotNull);
    });

    // ── Responsive breakpoint: threePaneMinWidth (wide — at split) ──────────

    testWidgets('wide at threePaneMinWidth: Scaffold.drawer is null', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNull);
    });

    testWidgets('wide at threePaneMinWidth: findings inline — no bottom sheet', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomSheet, isNull);
    });

    // ── Responsive breakpoint: threePaneMinWidth + 1 (wide — above split) ───

    testWidgets('wide above threePaneMinWidth: drawer is inline and Row is used', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.threePaneMinWidth + 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNull);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('renders ConversationDrawer slot', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationDrawer), findsOneWidget);
    });
  });
}
