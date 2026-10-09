import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/mocks/conversation_mocks.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingCaseRepository implements CaseRepository {
  @override
  Future<CaseDetail> getCaseDetail(String caseId) async {
    throw Exception('mock failure');
  }

  @override
  Future<List<CaseSummary>> getCases() async => const [];

  @override
  Future<List<CaseSummary>> getSimilarCases(String caseId) async => const [];
}

/// Lets each method fail independently -- one repository backs both
/// `conversationsProvider` and `messagesProvider` (see
/// `lib/services/providers.dart`).
class _FakeConversationRepository implements ConversationRepository {
  _FakeConversationRepository(
      {this.failConversations = false, this.failMessages = false});

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
  }) async =>
      addMockMessage(conversationId, text);
}

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // SettingsPage reads ThemeControllerScope.of(context) -- needed only for
  // the drawer-Settings test below (see home_hub_page_test.dart, where this
  // wrap-vs-wrapWithNav split was first needed: the scope must wrap
  // MaterialApp itself, not just `home`, since it has to cover routes
  // pushed later too).
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

  group('StudyReviewPage', () {
    testWidgets('renders StudyReviewTemplate', (tester) async {
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(StudyReviewTemplate), findsOneWidget);
    });

    testWidgets('renders Study Review in app bar', (tester) async {
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('Study Review'), findsOneWidget);
    });

    testWidgets('shows the whole study: the image is contained, not cropped',
        (tester) async {
      // The template stretches the viewer slot to fill its cell, so `cover`
      // would crop the study to fill it. Pixel data is evidence (DL §3.7).
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(
          tester.widget<AppImage>(find.byType(AppImage)).fit, BoxFit.contain);
    });

    testWidgets(
        'while providers are still resolving, renders the template (not a '
        'bypass Scaffold) -- app bar stays absent at the wide tier',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pump();

      expect(find.byType(StudyReviewTemplate), findsOneWidget);
      // One per independent section (imageViewer/findingsPanel share
      // caseDetailProvider; chatPanel's messageList has its own
      // messagesProvider) -- each shows its own loading state rather than
      // one page-wide flag, so a finding/message not yet loaded is never
      // silently indistinguishable from "none exist".
      expect(find.byType(AppLoadingIndicator), findsNWidgets(3));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.appBar, isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('renders FindingsPanel slot', (tester) async {
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(FindingsPanel), findsOneWidget);
    });

    testWidgets(
        'expanding a finding and tapping View Heatmap opens Heatmap Viewer',
        (tester) async {
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Right lower lobe consolidation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Heatmap'));
      await tester.pumpAndSettle();

      final page = tester.widget<HeatmapViewerPage>(
        find.byType(HeatmapViewerPage),
      );
      expect(page.findingId, 'finding-1');
    });

    testWidgets('tapping View Similar Studies opens Similar Cases',
        (tester) async {
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Similar Studies'));
      await tester.pumpAndSettle();

      final page =
          tester.widget<SimilarCasesPage>(find.byType(SimilarCasesPage));
      expect(page.caseId, 'case-1');
    });

    testWidgets('renders ChatPanel slot', (tester) async {
      // Wide, not the default size: below threePaneMinWidth, chat lives
      // inside the (unselected-by-default) second tab and isn't laid out.
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: below twoPaneMinWidth (narrow) ────────────────

    testWidgets('narrow below twoPaneMinWidth: TabBar is visible',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.twoPaneMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets(
        'narrow below twoPaneMinWidth: drawer assigned to Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.twoPaneMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    // ── Responsive breakpoint: twoPaneMinWidth to threePaneMinWidth ──────────
    // (viewer + tabs — still has a TabBar; nav and chat aren't yet separate
    // zones, so the drawer stays an overlay too)

    testWidgets('viewer + tabs at twoPaneMinWidth: TabBar still visible',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.twoPaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    testWidgets('tapping Settings in the drawer opens SettingsPage',
        (tester) async {
      // Narrow, not three-zone: onSettings/"Settings" is the drawer's
      // compact/medium behavior -- the wide-tier variant shows "Menu"
      // instead (covered by the "drawer: tapping ..." group below).
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        await wrapWithNav(const StudyReviewPage(caseId: 'case-1')),
      );
      await tester.pumpAndSettle();

      // At this tier the drawer is an overlay -- open it first.
      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(ConversationDrawer),
        matching: find.text('Settings'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // ── Responsive breakpoint: threePaneMinWidth (three-zone) ────────────────

    testWidgets('three-zone at threePaneMinWidth: no TabBar, Row layout',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(Row), findsWidgets);
    });

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────

    void setThreeZoneSize(WidgetTester tester) {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('drawer: opens with all 4 destinations, none selected',
        (tester) async {
      // Study Review isn't itself Home/Chat/Studies/Settings -- the
      // selectedIndex-null case, exhaustively unit-tested in
      // primary_nav_drawer_test.dart; this just confirms the page actually
      // wires PrimaryNavDrawer with a null selectedIndex, not one of the 4.
      setThreeZoneSize(tester);
      await tester.pumpWidget(wrap(const StudyReviewPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      // No app bar/hamburger at this tier anymore -- the repurposed bottom
      // "Menu" row inside the wide conversation drawer opens it instead.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      final drawer = tester.widget<PrimaryNavDrawer>(
        find.byType(PrimaryNavDrawer),
      );
      expect(drawer.selectedIndex, isNull);
    });

    testWidgets('drawer: tapping Home pops back to the root', (tester) async {
      setThreeZoneSize(tester);
      await tester.pumpWidget(await wrapWithNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StudyReviewPage(caseId: 'case-1'),
                  ),
                ),
                child: const Text('go to study review'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to study review'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Home'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(StudyReviewPage), findsNothing);
    });

    testWidgets('drawer: tapping Chat replaces with ChatPage', (tester) async {
      setThreeZoneSize(tester);
      await tester.pumpWidget(
        await wrapWithNav(const StudyReviewPage(caseId: 'case-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Chat'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(StudyReviewPage), findsNothing);
    });

    // ── Per-section error handling (a failed call used to spin forever) ────

    testWidgets(
        'shows an error message in the image and findings slots when the '
        'case detail fails to load', (tester) async {
      await tester.pumpWidget(wrap(
        const StudyReviewPage(caseId: 'case-1'),
        overrides: [
          caseRepositoryProvider.overrideWithValue(_FailingCaseRepository()),
        ],
      ));
      // The case-detail failure resolves almost instantly, but the other
      // providers this page watches (conversations, messages, current user)
      // still run their real mock delay underneath -- see the comment on
      // the drawer error test below for why this needs a longer step.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.textContaining('Could not load image'), findsOneWidget);
      expect(find.textContaining('Could not load findings'), findsOneWidget);
      expect(find.byType(FindingsPanel), findsNothing);
    });

    testWidgets(
        'shows an error message in the chat panel when messages fail to '
        'load', (tester) async {
      // ChatPanel only renders directly at the three-zone tier; narrower
      // tiers put it behind an unselected "Chat" tab (see "renders
      // ChatPanel slot" above).
      setThreeZoneSize(tester);
      await tester.pumpWidget(wrap(
        const StudyReviewPage(caseId: 'case-1'),
        overrides: [
          conversationRepositoryProvider.overrideWithValue(
            _FakeConversationRepository(failMessages: true),
          ),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.textContaining('Could not load messages'), findsOneWidget);
    });

    testWidgets('drawer shows an error when conversations fail to load',
        (tester) async {
      setThreeZoneSize(tester);
      await tester.pumpWidget(wrap(
        const StudyReviewPage(caseId: 'case-1'),
        overrides: [
          conversationRepositoryProvider.overrideWithValue(
            _FakeConversationRepository(failConversations: true),
          ),
        ],
      ));
      // The conversations failure resolves almost instantly, but the other
      // providers this page watches (case detail, messages, current user)
      // still run their real mock delay underneath -- pumpAndSettle's
      // default 100ms step can otherwise conclude "settled" before those
      // unrelated timers fire, leaving them pending at teardown.
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
  });
}
