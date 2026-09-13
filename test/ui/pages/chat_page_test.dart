import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Settings is one of the nav bar's destinations, and it reads
  // ThemeControllerScope.of(context) -- these tests need a real loaded
  // controller as an ancestor of MaterialApp itself (not just `home`, which
  // doesn't cover routes pushed/replaced later -- see home_hub_page_test.dart).
  Future<Widget> wrapWithNav(Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    return ProviderScope(
      child: ThemeControllerScope(
        controller: controller,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      ),
    );
  }

  group('ChatPage', () {
    testWidgets('renders ChatTemplate', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ChatTemplate), findsOneWidget);
    });

    testWidgets('renders Chat in app bar', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      // Not a bare find.text('Chat') -- the nav bar's own "Chat" destination
      // label now renders on this page too.
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Chat')),
        findsOneWidget,
      );
    });

    testWidgets('app bar title renders in headingMd, not the platform default',
        (tester) async {
      // Regression guard for gap 11: AppBar titles used to fall back to
      // Flutter's own Roboto Typography because buildAppTheme() set no
      // titleTextStyle and no textTheme.
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.byType(AppBar), matching: find.text('Chat')),
      );
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

    // ── Nav bar (own index 1) ────────────────────────────────────────────

    testWidgets('tapping Home in the nav bar pops back to the root',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                ),
                child: const Text('go to chat'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('tapping Studies in the nav bar replaces with CaseListPage',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Studies'));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('tapping Settings in the nav bar replaces with SettingsPage',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(ChatPage), findsNothing);
    });
  });
}
