import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';

import 'fixtures/case_repository_fixture.dart';
import 'fixtures/fixture_result.dart';

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
}
