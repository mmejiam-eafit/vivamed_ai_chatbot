import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/upload_zone.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/pages/upload_page.dart';

import 'fixtures/fixture_result.dart';
import 'fixtures/processing_repository_fixture.dart';

/// Two kinds of scenario. The fixture-backed ones override
/// `processingRepositoryProvider`, so they assert against the fixtures below
/// rather than the mocks. The last one runs the default mocks from the
/// Upload page on: the mock pipeline's run, read every two seconds in real
/// time, its two failures, a retry and a discard, then the study.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const finished = ProcessingRun(
    status: RunStatus.ready,
    openFailures: 1,
    steps: [
      ProcessingStep(
        stage: ProcessingStage.intake,
        state: ProcessingStepState.done,
      ),
      ProcessingStep(
        stage: ProcessingStage.prediction,
        state: ProcessingStepState.failed,
      ),
    ],
  );

  final labels = ProcessingFailure(
    stepId: 'fixture-step',
    stage: ProcessingStage.prediction,
    internalName: 'img-fixture',
    code: ProcessingErrorCode.modelUnavailable,
    attempts: 4,
    failedAt: DateTime.utc(2026, 11, 22, 10, 15),
    canRetry: true,
  );

  Widget wrap(ProcessingRepositoryFixture fixture, {String? runId}) =>
      ProviderScope(
        overrides: [processingRepositoryProvider.overrideWithValue(fixture)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: ProcessingPage(caseId: 'fixture-case', runId: runId),
        ),
      );

  // Real device runs use the host window, so pin a size.
  void setSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder button(String label) =>
      find.byWidgetPredicate((w) => w is AppButton && w.label == label);

  testWidgets('shows a spinner while the failed items load', (tester) async {
    setSize(tester);
    await tester.pumpWidget(wrap(ProcessingRepositoryFixture(
      getFailuresResult: const FixturePending(),
    )));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  testWidgets('a finished run shows its status, open failures and items',
      (tester) async {
    setSize(tester);
    await tester.pumpWidget(wrap(
      ProcessingRepositoryFixture(
        getRunResult: const FixtureSuccess(finished),
        getFailuresResult: FixtureSuccess([
          (caseId: 'fixture-case', failures: [labels]),
        ]),
      ),
      runId: 'fixture-run',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('1 open failure'), findsOneWidget);
    expect(find.text('img-fixture'), findsOneWidget);
    expect(
      find.text('Labels: A model could not be loaded. Try again later.'),
      findsOneWidget,
    );
    expect(button('Open study'), findsOneWidget);
  });

  testWidgets('a retried item leaves the list', (tester) async {
    setSize(tester);
    final fixture = ProcessingRepositoryFixture(
      getFailuresResult: FixtureSuccess([
        (caseId: 'fixture-case', failures: [labels]),
      ]),
      retryResult: const FixtureSuccess(null),
    );
    await tester.pumpWidget(wrap(fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('img-fixture'));
    await tester.pumpAndSettle();
    fixture.getFailuresResult = const FixtureSuccess([]);
    await tester.tap(button('Retry 1'));
    await tester.pumpAndSettle();

    expect(find.text('Retrying 1 item.'), findsOneWidget);
    expect(find.text('No failed items.'), findsOneWidget);
  });

  testWidgets('a failed discard keeps the item and says why', (tester) async {
    setSize(tester);
    await tester.pumpWidget(wrap(ProcessingRepositoryFixture(
      getFailuresResult: FixtureSuccess([
        (caseId: 'fixture-case', failures: [labels]),
      ]),
      discardResult: const FixtureFailure('fixture discard failure'),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('img-fixture'));
    await tester.pumpAndSettle();
    await tester.tap(button('Discard 1'));
    await tester.pumpAndSettle();
    await tester.tap(button('Discard'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not discard: Exception: fixture discard failure'),
      findsOneWidget,
    );
    expect(find.text('img-fixture'), findsOneWidget);
  });

  /// Pumps until [finder] finds something, in real time: the mock pipeline
  /// is read every two seconds, which no frame waits for.
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets(
      'with the mocks: upload -> follow the run -> retry -> discard -> study',
      (tester) async {
    setSize(tester);
    Future<List<String>?> threeFiles() async => ['1.dcm', '2.dcm', '3.dcm'];
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(),
        home: UploadPage(pickFiles: threeFiles),
      ),
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    expect(find.byType(ProcessingPage), findsOneWidget);

    // The mock run fails the third file and the second file's labels.
    await pumpUntilFound(tester, find.text('Ready'));
    await pumpUntilFound(tester, find.text('7f3a2101-002'));
    expect(find.text('2 open failures'), findsOneWidget);
    expect(find.text('7f3a2101-003'), findsOneWidget);

    // Retrying the labels reopens the run; this time they succeed.
    await tester.tap(find.text('7f3a2101-002'));
    await tester.pumpAndSettle();
    await tester.tap(button('Retry 1'));
    await tester.pumpAndSettle();
    expect(find.text('Retrying 1 item.'), findsOneWidget);
    await pumpUntilFound(tester, find.text('1 open failure'));
    await pumpUntilFound(tester, find.text('Ready'));
    expect(find.text('7f3a2101-002'), findsNothing);

    // The file in a format the pipeline can't read is discarded.
    await tester.tap(find.text('7f3a2101-003'));
    await tester.pumpAndSettle();
    await tester.tap(button('Discard 1'));
    await tester.pumpAndSettle();
    await tester.tap(button('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Discarded 1 item.'), findsOneWidget);
    expect(find.text('No failed items.'), findsOneWidget);

    await tester.tap(button('Open study'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyReviewPage), findsOneWidget);
    expect(find.textContaining('failed processing'), findsNothing);
  });

  testWidgets(
      'with the mocks: leave a run mid-way -> Studies shows it under way -> '
      'follow it again -> Studies shows it ready', (tester) async {
    setSize(tester);
    Future<List<String>?> threeFiles() async => ['1.dcm', '2.dcm', '3.dcm'];
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        navigatorKey: navigator,
        theme: buildAppTheme(),
        home: const CaseListPage(),
      ),
    ));
    await tester.pumpAndSettle();

    // Upload from over the worklist; the Processing page replaces Upload.
    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => UploadPage(pickFiles: threeFiles),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(UploadZone));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    expect(find.byType(ProcessingPage), findsOneWidget);

    // Leave before the run ends: the worklist reads at once on its return,
    // and the new study is still under way.
    navigator.currentState!.pop();
    await pumpUntilFound(tester, find.text('New Patient'));
    // Once the Processing page and its own "Processing" title are gone.
    await tester.pumpAndSettle();
    expect(find.byType(ProcessingPage), findsNothing);
    final upload = tester
        .widget<CaseWorklistTable>(find.byType(CaseWorklistTable))
        .cases
        .singleWhere((c) => c.patient == 'New Patient');
    // Its third file may already have failed by now ("Processing · 1 failed
    // item"), so the row is checked by its data, not its exact words.
    expect(upload.status.inProgress, isTrue);
    expect(upload.activeRunId, MockPipeline.uploadRunId(1));
    expect(find.text(upload.statusSummary), findsOneWidget);

    // Its row leads back to the run's progress.
    await tester.tap(find.text('New Patient'));
    await tester.pumpAndSettle();
    final page = tester.widget<ProcessingPage>(find.byType(ProcessingPage));
    expect(page.runId, MockPipeline.uploadRunId(1));
    await pumpUntilFound(tester, find.text('Ready'));

    navigator.currentState!.pop();
    await pumpUntilFound(tester, find.text('Ready · 2 failed items'));
  });
}
