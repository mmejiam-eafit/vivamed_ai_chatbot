import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/mocks/conversation_mocks.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets each method fail independently, so a test can simulate e.g.
/// "conversations load fine, but this conversation's messages fail" -- a
/// single repository backs both `conversationsProvider` and
/// `messagesProvider` (see `lib/services/providers.dart`).
class _FakeConversationRepository implements ConversationRepository {
  _FakeConversationRepository({
    this.failConversations = false,
    this.failMessages = false,
  });

  final bool failConversations;
  final bool failMessages;

  @override
  Future<List<ConversationItem>> getConversations() async {
    if (failConversations) throw Exception('mock failure');
    return mockConversations;
  }

  @override
  Future<List<ChatMessageItem>> getMessages(String conversationId) async {
    if (failMessages) throw Exception('mock failure');
    return mockMessagesFor(conversationId);
  }

  @override
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  }) async => addMockMessage(conversationId, text);
}

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
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

    testWidgets(
      'while providers are still resolving, renders the template (not a '
      'bypass Scaffold) -- app bar stays absent at the wide tier',
      (tester) async {
        tester.view.physicalSize = const Size(
          AppLayout.threePaneMinWidth * 3,
          844 * 3,
        );
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(wrap(const ChatPage()));
        await tester.pump();

        expect(find.byType(ChatTemplate), findsOneWidget);
        expect(find.byType(AppLoadingIndicator), findsOneWidget);
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.appBar, isNull);

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'app bar title renders in headingMd, not the platform default',
      (tester) async {
        // Regression guard for gap 11: AppBar titles used to fall back to
        // Flutter's own Roboto Typography because buildAppTheme() set no
        // titleTextStyle and no textTheme.
        await tester.pumpWidget(wrap(const ChatPage()));
        await tester.pumpAndSettle();

        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: find.byType(AppBar), matching: find.text('Chat')),
        );
        expect(
          paragraph.text.style?.fontFamily,
          AppTypography.headingMd.fontFamily,
        );
      },
    );

    testWidgets('renders ChatPanel slot', (tester) async {
      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: threePaneMinWidth - 1 (narrow) ────────────────

    testWidgets(
      'narrow below threePaneMinWidth: drawer assigned to Scaffold.drawer',
      (tester) async {
        tester.view.physicalSize = const Size(
          (AppLayout.threePaneMinWidth - 1) * 3,
          844 * 3,
        );
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(wrap(const ChatPage()));
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.drawer, isNotNull);
      },
    );

    // ── Responsive breakpoint: threePaneMinWidth (wide — at split) ──────────

    testWidgets('wide at threePaneMinWidth: Scaffold.drawer is the primary nav '
        'drawer, conversation history renders inline', (tester) async {
      tester.view.physicalSize = const Size(
        AppLayout.threePaneMinWidth * 3,
        844 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isA<PrimaryNavDrawer>());
      expect(find.byType(ConversationDrawer), findsOneWidget);
    });

    // ── Responsive breakpoint: threePaneMinWidth + 1 (wide — above split) ───

    testWidgets(
      'wide above threePaneMinWidth: conversation history is inline and '
      'Row is used',
      (tester) async {
        tester.view.physicalSize = const Size(
          (AppLayout.threePaneMinWidth + 1) * 3,
          844 * 3,
        );
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(wrap(const ChatPage()));
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.drawer, isA<PrimaryNavDrawer>());
        expect(find.byType(ConversationDrawer), findsOneWidget);
        expect(find.byType(Row), findsWidgets);
      },
    );

    testWidgets(
      'tapping a case reference chip opens Study Review with the same conversation',
      (tester) async {
        await tester.pumpWidget(wrap(const ChatPage()));
        await tester.pumpAndSettle();

        // From the mock conv-1 message referencing case-2 ("Abdominal CT") --
        // it's the newest message, so the lazy message list needs scrolling
        // to it first.
        await tester.scrollUntilVisible(
          find.text('Abdominal CT'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        // scrollUntilVisible ends in ensureVisible, which jumps the list without
        // pumping a frame; tap reads positions from the last layout, so let one run.
        await tester.pump();
        await tester.tap(find.text('Abdominal CT'));
        await tester.pumpAndSettle();

        final page = tester.widget<StudyReviewPage>(
          find.byType(StudyReviewPage),
        );
        expect(page.caseId, 'case-2');
        expect(page.conversationId, 'conv-1');
      },
    );

    testWidgets('renders ConversationDrawer slot', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationDrawer), findsOneWidget);
    });

    // ── Conversation switching (real local state, not a route) ──────────────

    testWidgets('the default conversation (first in the list) is selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      final drawer = tester.widget<ConversationDrawer>(
        find.byType(ConversationDrawer),
      );
      expect(drawer.selectedId, 'conv-1');
    });

    testWidgets('tapping a different conversation in the drawer switches it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const ChatPage()));
      await tester.pumpAndSettle();

      // conv-2's title, from the mock conversation list.
      await tester.tap(find.text('Abdominal CT — Patient 2'));
      await tester.pumpAndSettle();

      final drawer = tester.widget<ConversationDrawer>(
        find.byType(ConversationDrawer),
      );
      expect(drawer.selectedId, 'conv-2');
    });

    testWidgets('tapping Settings in the drawer opens SettingsPage', (
      tester,
    ) async {
      // Compact, not wide: onSettings/"Settings" is the drawer's
      // compact/medium behavior -- the wide-tier variant shows "Menu"
      // instead (covered by the "drawer: tapping ..." group below).
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // SettingsPage reads ThemeControllerScope.of(context) -- wrapWithNav,
      // not wrap, same as this file's other tests that land on it.
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();

      // Not a bare find.text('Settings') -- the nav bar has its own
      // "Settings" destination label on screen at the same time.
      await tester.tap(
        find.descendant(
          of: find.byType(ConversationDrawer),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // Pushed, not replaced -- popping returns to ChatPage. (Can't check
      // this by looking for ChatPage while SettingsPage is on top: Flutter's
      // Navigator stops building fully-covered routes once settled, so it
      // wouldn't be found either way.)
      Navigator.of(tester.element(find.byType(SettingsPage))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);
    });

    // ── Nav bar (own index 1) ────────────────────────────────────────────

    testWidgets('tapping Home in the nav bar pops back to the root', (
      tester,
    ) async {
      await tester.pumpWidget(
        await wrapWithNav(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ChatPage())),
                  child: const Text('go to chat'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('tapping Studies in the nav bar replaces with CaseListPage', (
      tester,
    ) async {
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Studies'));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('tapping Settings in the nav bar replaces with SettingsPage', (
      tester,
    ) async {
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(ChatPage), findsNothing);
    });

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────

    void setWideSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('drawer: tapping Home pops back to the root', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(
        await wrapWithNav(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ChatPage())),
                  child: const Text('go to chat'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);

      // No app bar/hamburger at this tier anymore -- the repurposed bottom
      // "Menu" row inside the wide conversation drawer opens it instead.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text('Home')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('drawer: tapping Studies replaces with CaseListPage', (
      tester,
    ) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrapWithNav(const ChatPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Studies'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(ChatPage), findsNothing);
    });

    testWidgets('drawer shows an error when conversations fail to load', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(
          const ChatPage(),
          overrides: [
            conversationRepositoryProvider.overrideWithValue(
              _FakeConversationRepository(failConversations: true),
            ),
          ],
        ),
      );
      // The conversations failure resolves almost instantly, but
      // currentUserProvider (unrelated to this scenario, unused in the
      // error path) still runs the real 300ms mock delay underneath --
      // pumpAndSettle's default 100ms step can otherwise conclude "settled"
      // before that unrelated timer fires, leaving it pending at teardown.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.byType(ConversationDrawer), findsNothing);
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.textContaining('Could not load conversations'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'message list shows an error when messages fail to load for the '
      'resolved conversation',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ChatPage(),
            overrides: [
              conversationRepositoryProvider.overrideWithValue(
                _FakeConversationRepository(failMessages: true),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Could not load messages'), findsOneWidget);
      },
    );
  });
}
