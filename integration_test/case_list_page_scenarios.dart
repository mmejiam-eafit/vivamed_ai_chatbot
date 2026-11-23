import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';

import 'fixtures/case_repository_fixture.dart';
import 'fixtures/fixture_result.dart';
import 'fixtures/processing_repository_fixture.dart';

/// Fixture-backed scenarios: they override `caseRepositoryProvider` directly,
/// so these assert against known fixture values rather than
/// `lib/data/mocks/case_mocks.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Real device runs use the actual host window size, not flutter_test's
  // small fixed default -- that's wide enough to trip CaseListTemplate into
  // its three-pane CaseWorklistTable tier instead of the StudyInfoCard list
  // these tests assert against. Forced narrow, matching the other page
  // tests' narrow-tier convention.
  void setNarrowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('success with cases renders the fixture case title',
      (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getCasesResult: FixtureSuccess([
        CaseSummary(
          id: 'fixture-1',
          title: 'Fixture Case One',
          patient: 'Fixture Patient A',
          modality: 'CXR',
          date: DateTime(2026, 1, 1),
          confidence: 0.8,
          severity: SeverityLevel.normal,
        ),
      ]),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Fixture Case One'), findsOneWidget);
  });

  testWidgets('empty list shows the empty state', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getCasesResult: const FixtureSuccess([]),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('No cases available.'), findsOneWidget);
  });

  testWidgets('failure shows the error text', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getCasesResult: const FixtureFailure('fixture cases failure'),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load cases'), findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getCasesResult: const FixturePending(),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  // ── Status (DL D-024) ──────────────────────────────────────────────────

  CaseSummary fixtureStudy(
    String id,
    String title, {
    StudyStatus status = StudyStatus.ready,
    int openFailures = 0,
  }) =>
      CaseSummary(
        id: id,
        title: title,
        patient: 'Fixture Patient $id',
        modality: 'CXR',
        date: DateTime(2026, 1, 1),
        confidence: 0.8,
        severity: SeverityLevel.normal,
        status: status,
        openFailures: openFailures,
      );

  testWidgets('each card says where its study stands', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getCasesResult: FixtureSuccess([
        fixtureStudy('fixture-1', 'Fixture Case One',
            status: StudyStatus.needsReview),
        fixtureStudy('fixture-2', 'Fixture Case Two', openFailures: 2),
      ]),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Ready · 2 failed items'), findsOneWidget);
  });

  testWidgets('a failed study with open failures opens its failed items',
      (tester) async {
    setNarrowSize(tester);
    final cases = CaseRepositoryFixture(
      getCasesResult: FixtureSuccess([
        fixtureStudy(
          'fixture-1',
          'Fixture Case One',
          status: StudyStatus.failed,
          openFailures: 1,
        ),
      ]),
    );
    final processing = ProcessingRepositoryFixture(
      getFailuresResult: FixtureSuccess([
        (
          caseId: 'fixture-1',
          failures: [
            ProcessingFailure(
              stepId: 'step-1',
              stage: ProcessingStage.intake,
              internalName: '0f1a2b3c-001',
              code: ProcessingErrorCode.unsupportedPixelData,
              attempts: 1,
              failedAt: DateTime.utc(2026, 11, 23, 9, 30),
              canRetry: true,
            ),
          ],
        ),
      ]),
    );
    await tester.pumpWidget(wrap(
      const CaseListPage(),
      overrides: [
        caseRepositoryProvider.overrideWithValue(cases),
        processingRepositoryProvider.overrideWithValue(processing),
      ],
    ));
    await tester.pumpAndSettle();
    expect(find.text('Failed · 1 failed item'), findsOneWidget);

    await tester.tap(find.text('Fixture Case One'));
    await tester.pumpAndSettle();

    final page = tester.widget<ProcessingPage>(find.byType(ProcessingPage));
    expect(page.caseId, 'fixture-1');
    expect(page.runId, isNull);
    expect(find.text('0f1a2b3c-001'), findsOneWidget);
  });
}
