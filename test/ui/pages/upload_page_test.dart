import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/processing_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/data/upload.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/pages/upload_page.dart';

import '../../support/fake_processing_repository.dart';

class _FailingUploadRepository implements UploadRepository {
  int calls = 0;

  @override
  Future<UploadResult> uploadStudy(List<String> fileNames) async {
    calls++;
    throw Exception('mock failure');
  }
}

/// Every file was already in the study: no run to follow.
class _DuplicateUploadRepository implements UploadRepository {
  @override
  Future<UploadResult> uploadStudy(List<String> fileNames) async =>
      const UploadResult(caseId: 'case-6');
}

void main() {
  // The mock upload's first run in a fresh pipeline; answered as
  // finished, so the Processing page it leads to reads it once and settles.
  List<Override> finishedRun() => [
        processingRepositoryProvider.overrideWithValue(
          FakeProcessingRepository(runs: {
            MockPipeline.uploadRunId(1): [
              const ProcessingRun(
                status: RunStatus.ready,
                openFailures: 0,
                steps: [],
              ),
            ],
          }),
        ),
      ];

  Widget wrap(
    Widget child, {
    List<Override> overrides = const [],
  }) =>
      ProviderScope(
        overrides: [...finishedRun(), ...overrides],
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  Future<List<String>?> noFiles() async => null;
  Future<List<String>?> threeFiles() async => ['1.dcm', '2.dcm', '3.dcm'];

  testWidgets('Upload button starts disabled with no files selected',
      (tester) async {
    await tester.pumpWidget(wrap(UploadPage(pickFiles: noFiles)));

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('picking files shows the count and enables Upload', (tester) async {
    await tester.pumpWidget(wrap(UploadPage(pickFiles: threeFiles)));

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.text('3 files selected'), findsOneWidget);
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
      'uploading succeeds: follows the run on the Processing page '
      'automatically', (tester) async {
    await tester.pumpWidget(wrap(UploadPage(pickFiles: threeFiles)));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pump(); // enter 'uploading'
    final duringButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(duringButton.onPressed, isNull);

    await tester.pumpAndSettle();

    // No manual step: navigation happens as soon as the files are stored,
    // with no intervening "View Study" banner/button to tap.
    final page = tester.widget<ProcessingPage>(find.byType(ProcessingPage));
    expect(page.runId, MockPipeline.uploadRunId(1));
    expect(page.caseId, startsWith('case-upload-'));
    expect(find.byType(UploadPage), findsNothing);
    expect(find.text('View Study'), findsNothing);
  });

  testWidgets('an upload with nothing to process goes straight to the study',
      (tester) async {
    await tester.pumpWidget(wrap(
      UploadPage(pickFiles: threeFiles),
      overrides: [
        uploadRepositoryProvider
            .overrideWithValue(_DuplicateUploadRepository()),
      ],
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    final page = tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
    expect(page.caseId, 'case-6');
    expect(find.byType(ProcessingPage), findsNothing);
  });

  testWidgets('back navigation is blocked while uploading', (tester) async {
    // Only the busy-state assertion: a successful upload now navigates away
    // immediately once settled, so there's no PopScope left on this page to
    // re-check afterward -- that "unblocked again" case is covered by the
    // failure path below instead, where the page is still there to ask.
    await tester.pumpWidget(wrap(UploadPage(pickFiles: threeFiles)));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pump();

    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);

    // Drain the pending mock-upload timer/navigation rather than leaving it
    // pending when the test ends.
    await tester.pumpAndSettle();
  });

  testWidgets('a failed upload shows Retry, which re-attempts with the same files',
      (tester) async {
    final failingRepository = _FailingUploadRepository();
    await tester.pumpWidget(wrap(
      UploadPage(pickFiles: threeFiles),
      overrides: [
        uploadRepositoryProvider.overrideWithValue(failingRepository),
      ],
    ));
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    expect(find.text('Upload failed. Please try again.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(failingRepository.calls, 1);
    // Busy state clears on failure -- back navigation is unblocked again
    // (the page stays put on failure, unlike the success path).
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isTrue);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(failingRepository.calls, 2);
    expect(find.text('Upload failed. Please try again.'), findsOneWidget);
  });
}
