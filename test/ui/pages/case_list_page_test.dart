import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/review_queue_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One study, always processing, and a count of the worklist's reads.
class _CountingCaseRepository implements CaseRepository {
  var reads = 0;

  @override
  Future<List<CaseSummary>> getCases() async {
    reads++;
    return [
      CaseSummary(
        id: 'case-1',
        title: 'Chest X-Ray',
        patient: 'Anonymous 1',
        modality: 'CXR',
        date: DateTime(2026, 11, 1),
        confidence: 0.9,
        severity: SeverityLevel.mild,
        status: StudyStatus.processing,
        activeRunId: 'run-1',
      ),
    ];
  }

  @override
  Future<CaseDetail> getCaseDetail(String caseId) =>
      throw UnimplementedError();

  @override
  Future<SimilarCases> getSimilarCases(String caseId) =>
      throw UnimplementedError();
}

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

    testWidgets(
        'while cases are still loading, renders the template (not a bypass '
        'Scaffold) -- app bar stays absent at the wide tier', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pump();

      expect(find.byType(CaseListTemplate), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.appBar, isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('renders Cases in app bar', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Cases'), findsOneWidget);
    });

    testWidgets('renders placeholder case cards', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(StudyInfoCard), findsNWidgets(mockCases.length));
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
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
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

    // ── Responsive breakpoint: threePaneMinWidth (worklist table) ───────────

    testWidgets('expanded: renders CaseWorklistTable slot, no grid or list',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CaseWorklistTable), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Status (DL D-024) ────────────────────────────────────────────

    testWidgets('cards say where each study stands', (tester) async {
      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      // case-6 has a decision being applied and three open failures;
      // case-7 and case-8 each have an image awaiting review.
      expect(find.text('Processing · 3 failed items'), findsOneWidget);
      expect(find.text('Needs review'), findsNWidgets(2));
      expect(find.text('Ready'), findsNWidgets(5));
      expect(
        find.descendant(
          of: find.byType(StudyInfoCard),
          matching: find.text('Status'),
        ),
        findsNWidgets(mockCases.length),
      );
    });

    testWidgets('the worklist shows each study with its status',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const CaseListPage()));
      await tester.pumpAndSettle();

      final table =
          tester.widget<CaseWorklistTable>(find.byType(CaseWorklistTable));
      final case6 = table.cases.singleWhere((c) => c.id == 'case-6');
      expect(case6.status, StudyStatus.processing);
      expect(case6.openFailures, 3);
      expect(find.text('Processing · 3 failed items'), findsOneWidget);
    });

    // ── Reading again only while visible ───────────────────────────────

    group('while a study is in progress', () {
      late _CountingCaseRepository repository;
      final navigatorKey = GlobalKey<NavigatorState>();

      Widget app() => ProviderScope(
            overrides: [caseRepositoryProvider.overrideWithValue(repository)],
            child: MaterialApp(
              navigatorKey: navigatorKey,
              theme: buildAppTheme(),
              home: const CaseListPage(),
            ),
          );

      setUp(() => repository = _CountingCaseRepository());

      testWidgets('reads again every 5 seconds', (tester) async {
        await tester.pumpWidget(app());
        await tester.pump();
        expect(repository.reads, 1);

        await tester.pump(const Duration(seconds: 5));
        expect(repository.reads, 2);
      });

      testWidgets('stops reading while another page covers it, and reads at '
          'once when it is back', (tester) async {
        await tester.pumpWidget(app());
        await tester.pump();

        navigatorKey.currentState!.push(MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('cover')),
        ));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 30));
        expect(repository.reads, 1);

        navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        expect(repository.reads, 2);
      });

      testWidgets('stops reading while the app is hidden, and reads at once '
          'when it is shown', (tester) async {
        await tester.pumpWidget(app());
        await tester.pump();

        tester.binding
          ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
          ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        await tester.pump();
        await tester.pump(const Duration(seconds: 30));
        expect(repository.reads, 1);

        tester.binding
          ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
          ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        expect(repository.reads, 2);
      });

      testWidgets('keeps reading while the app is shown but unfocused',
          (tester) async {
        await tester.pumpWidget(app());
        await tester.pump();

        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump(const Duration(seconds: 5));
        expect(repository.reads, 2);

        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      });
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

    testWidgets('tapping Review in the nav bar replaces with ReviewQueuePage',
        (tester) async {
      await tester.pumpWidget(await wrapWithNav(const CaseListPage()));
      await tester.pumpAndSettle();

      // Scoped to the bar, so the tap can only reach its destination.
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Review'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewQueuePage), findsOneWidget);
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

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────

    void setWideSize(WidgetTester tester) {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('drawer: tapping Home pops back to the root', (tester) async {
      setWideSize(tester);
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

      // No app bar/hamburger at this tier anymore -- MenuRail's own "Menu"
      // trigger opens it instead.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Home'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsNothing);
    });

    testWidgets('drawer: tapping Chat replaces with ChatPage', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrapWithNav(const CaseListPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Chat'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(CaseListPage), findsNothing);
    });
  });
}
