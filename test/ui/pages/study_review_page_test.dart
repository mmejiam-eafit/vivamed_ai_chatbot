import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
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

    testWidgets('narrow below twoPaneMinWidth: drawer assigned to Scaffold.drawer',
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
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        await wrapWithNav(const StudyReviewPage(caseId: 'case-1')),
      );
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
  });
}
