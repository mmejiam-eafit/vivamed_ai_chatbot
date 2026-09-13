import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';
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

  group('CaseListPage', () {
    testWidgets('renders CaseListTemplate', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListTemplate), findsOneWidget);
    });

    testWidgets('renders Cases in app bar', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Cases'), findsOneWidget);
    });

    testWidgets('renders placeholder case cards', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(StudyInfoCard), findsNWidgets(6));
    });

    testWidgets('renders case titles', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Chest X-Ray'), findsOneWidget);
      expect(find.text('Abdominal CT'), findsOneWidget);
    });

    testWidgets('tapping a case card opens Study Review for that case',
        (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chest X-Ray'));
      await tester.pumpAndSettle();

      expect(find.byType(StudyReviewPage), findsOneWidget);
    });

    testWidgets('tapping a worklist row opens Study Review for that case',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      // The worklist table's columns are patient/modality/date/confidence/
      // severity -- no title column, so tap by patient name.
      await tester.tap(find.text('Anonymous 1'));
      await tester.pumpAndSettle();

      final page =
          tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
      expect(page.caseId, 'case-1');
    });

    // ── Responsive breakpoint: mediumMinWidth - 1 (narrow) ───────────────────

    testWidgets('narrow below mediumMinWidth: ListView visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.mediumMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    // ── Responsive breakpoint: mediumMinWidth (wide — at split) ──────────────

    testWidgets('wide at mediumMinWidth: two-column Wrap visible', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Responsive breakpoint: mediumMinWidth + 1 (wide — above split) ───────

    testWidgets('wide above mediumMinWidth: two-column Wrap visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.mediumMinWidth + 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Responsive breakpoint: expandedMinWidth (worklist table) ────────────

    testWidgets('expanded: renders CaseWorklistTable slot, no grid or list',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CaseWorklistTable), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Nav bar (own index 2) ────────────────────────────────────────────

    testWidgets('tapping Home in the nav bar pops back to the root',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaseListPage()),
                ),
                child: const Text('go to cases'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to cases'));
      await tester.pumpAndSettle();
      expect(find.byType(CaseListPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsNothing);
    });

    testWidgets('tapping Chat in the nav bar replaces with ChatPage',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(const CaseListPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(CaseListPage), findsNothing);
    });

    testWidgets('tapping Settings in the nav bar replaces with SettingsPage',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(const CaseListPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(CaseListPage), findsNothing);
    });
  });
}
