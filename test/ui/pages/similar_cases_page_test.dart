import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Settings is reachable from the wide-tier drawer here too, and it reads
  // ThemeControllerScope.of(context) -- needs a real loaded controller as an
  // ancestor of MaterialApp itself (see home_hub_page_test.dart, where this
  // wrap-vs-wrapWithNav split was first needed).
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

  void setWideSize(WidgetTester tester) {
    tester.view.physicalSize =
        const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('SimilarCasesPage', () {
    testWidgets('renders CaseListTemplate', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListTemplate), findsOneWidget);
    });

    testWidgets('renders Similar Cases in app bar', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('Similar Cases'), findsOneWidget);
    });

    testWidgets('renders a pluralized count header', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('3 similar cases found'), findsOneWidget);
    });

    testWidgets('a study searched with every image shows no basis line',
        (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Based on'), findsNothing);
    });

    testWidgets('a study with an image held back says which images it used',
        (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-7')));
      await tester.pumpAndSettle();

      expect(
        find.text('Based on 2 of 3 images; 1 held back for review'),
        findsOneWidget,
      );
    });

    testWidgets('a study held back entirely says why there are no cases',
        (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-6')));
      await tester.pumpAndSettle();

      expect(
        find.text(
            "No similar cases yet: this study's images are held back for "
            'review.'),
        findsOneWidget,
      );
      expect(find.text('No similar cases found.'), findsNothing);
    });

    testWidgets('excludes the given case from the results', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('Chest X-Ray'), findsNothing);
      expect(find.byType(StudyInfoCard), findsNWidgets(3));
    });

    testWidgets('tapping a result opens Study Review for that case',
        (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abdominal CT'));
      await tester.pumpAndSettle();

      final page =
          tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
      expect(page.caseId, 'case-2');
    });

    testWidgets(
        'while similar cases are still loading, renders the template (not '
        'a bypass Scaffold) -- app bar stays absent at the wide tier',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pump();

      expect(find.byType(CaseListTemplate), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.appBar, isNull);

      await tester.pumpAndSettle();
    });

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────
    //
    // Not one of the 4 primary destinations itself (a drill-down page, like
    // Study Review) -- CaseListPage already wires primaryNavDrawer/menuRail
    // for its own "Studies" destination, but this page previously wired
    // neither, leaving no way back at all once its app bar is hidden here.

    testWidgets('drawer: opens with all 4 destinations, none selected',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(Drawer), matching: find.text('Home')),
          findsOneWidget);
      expect(
          find.descendant(of: find.byType(Drawer), matching: find.text('Chat')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(Drawer), matching: find.text('Studies')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(Drawer), matching: find.text('Settings')),
          findsOneWidget);
    });

    testWidgets('drawer: tapping Home pops back to the root', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrapWithNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SimilarCasesPage(caseId: 'case-1'),
                  ),
                ),
                child: const Text('go to similar cases'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to similar cases'));
      await tester.pumpAndSettle();
      expect(find.byType(SimilarCasesPage), findsOneWidget);

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Home'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SimilarCasesPage), findsNothing);
    });

    testWidgets('drawer: tapping Studies replaces with CaseListPage',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(
        await wrapWithNav(const SimilarCasesPage(caseId: 'case-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Studies'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(SimilarCasesPage), findsNothing);
    });

    testWidgets('drawer: tapping Chat replaces with ChatPage', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(
        await wrapWithNav(const SimilarCasesPage(caseId: 'case-1')),
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
      expect(find.byType(SimilarCasesPage), findsNothing);
    });

    testWidgets('drawer: tapping Settings replaces with SettingsPage',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(
        await wrapWithNav(const SimilarCasesPage(caseId: 'case-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Settings'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(SimilarCasesPage), findsNothing);
    });
  });
}
