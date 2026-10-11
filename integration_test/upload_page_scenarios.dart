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
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/pages/upload_page.dart';

import 'fixtures/fixture_result.dart';
import 'fixtures/upload_repository_fixture.dart';

/// Fixture-backed scenarios: they override `uploadRepositoryProvider`
/// directly, so these assert against known fixture values rather than
/// `lib/data/mocks/case_mocks.dart`'s current content, and stay valid once a
/// real backend replaces the mock.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  Future<List<String>?> threeFiles() async => ['1.dcm', '2.dcm', '3.dcm'];

  testWidgets('upload success navigates to Study Review with the fixture case',
      (tester) async {
    final fixture = UploadRepositoryFixture(
      uploadStudyResult: FixtureSuccess(CaseDetail(
        caseSummary: CaseSummary(
          id: 'fixture-case-upload',
          title: 'Fixture Uploaded Study',
          patient: 'Fixture Patient',
          modality: 'CXR',
          date: DateTime(2026, 1, 1),
          confidence: 0.9,
          severity: SeverityLevel.normal,
        ),
        imageUrl: 'https://example.invalid/fixture.png',
      )),
    );
    await tester.pumpWidget(wrap(
      UploadPage(pickFiles: threeFiles),
      overrides: [uploadRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    final page = tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
    expect(page.caseId, 'fixture-case-upload');
  });

  testWidgets(
      'upload failure shows Retry; retrying with a fixed fixture succeeds',
      (tester) async {
    final fixture = UploadRepositoryFixture(
      uploadStudyResult: const FixtureFailure('fixture upload failure'),
    );
    await tester.pumpWidget(wrap(
      UploadPage(pickFiles: threeFiles),
      overrides: [uploadRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    expect(find.text('Upload failed. Please try again.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    fixture.uploadStudyResult = FixtureSuccess(CaseDetail(
      caseSummary: CaseSummary(
        id: 'fixture-case-retry',
        title: 'Fixture Retried Study',
        patient: 'Fixture Patient',
        modality: 'CXR',
        date: DateTime(2026, 1, 1),
        confidence: 0.9,
        severity: SeverityLevel.normal,
      ),
      imageUrl: 'https://example.invalid/fixture.png',
    ));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    final page = tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
    expect(page.caseId, 'fixture-case-retry');
  });

  testWidgets('while uploading, shows the busy state', (tester) async {
    final fixture = UploadRepositoryFixture(
      uploadStudyResult: const FixturePending(),
    );
    await tester.pumpWidget(wrap(
      UploadPage(pickFiles: threeFiles),
      overrides: [uploadRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    // Not pumpAndSettle -- the fixture's Future never resolves, so settling
    // would hang; a single pump is enough to reach the busy state.
    await tester.pump();
    await tester.pump(const Duration(
        milliseconds: 500)); // past the internal 400ms choreography delay

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });
}
