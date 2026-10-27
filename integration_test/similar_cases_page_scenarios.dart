import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';

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

  // Real device runs use the actual host window size -- forced narrow so
  // CaseListTemplate renders its StudyInfoCard list, not CaseWorklistTable
  // (see case_list_page_scenarios.dart for the full explanation).
  void setNarrowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('success excludes the source case and shows the count header',
      (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult: FixtureSuccess(SimilarCases(
        cases: [
          CaseSummary(
            id: 'fixture-similar-1',
            title: 'Fixture Similar Case',
            patient: 'Fixture Patient B',
            modality: 'CXR',
            date: DateTime(2026, 1, 1),
            confidence: 0.7,
            severity: SeverityLevel.mild,
          ),
        ],
        imagesUsed: 1,
        imagesTotal: 1,
        imagesHeldBack: 0,
      )),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('1 similar case found'), findsOneWidget);
    expect(find.text('Fixture Similar Case'), findsOneWidget);
  });

  testWidgets('a search on part of the study says which images it used',
      (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult: FixtureSuccess(SimilarCases(
        cases: [
          CaseSummary(
            id: 'fixture-similar-1',
            title: 'Fixture Similar Case',
            patient: 'Fixture Patient B',
            modality: 'CXR',
            date: DateTime(2026, 1, 1),
            confidence: 0.7,
            severity: SeverityLevel.mild,
          ),
        ],
        imagesUsed: 1,
        imagesTotal: 2,
        imagesHeldBack: 1,
      )),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(
      find.text('Based on 1 of 2 images; 1 held back for review'),
      findsOneWidget,
    );
  });

  testWidgets('a study held back entirely says why there are no cases',
      (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult: const FixtureSuccess(SimilarCases(
        cases: [],
        imagesUsed: 0,
        imagesTotal: 1,
        imagesHeldBack: 1,
      )),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(
      find.text(
          "No similar cases yet: this study's images are held back for review."),
      findsOneWidget,
    );
  });

  testWidgets('empty result shows the empty state', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult: const FixtureSuccess(SimilarCases(
        cases: [],
        imagesUsed: 1,
        imagesTotal: 1,
        imagesHeldBack: 0,
      )),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('No similar cases found.'), findsOneWidget);
  });

  testWidgets('failure shows the error text', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult:
          const FixtureFailure('fixture similar-cases failure'),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load similar cases'), findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    setNarrowSize(tester);
    final fixture = CaseRepositoryFixture(
      getSimilarCasesResult: const FixturePending(),
    );
    await tester.pumpWidget(wrap(
      const SimilarCasesPage(caseId: 'source-case'),
      overrides: [caseRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });
}
