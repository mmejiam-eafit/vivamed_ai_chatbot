import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/open_case.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

import '../../support/fake_processing_repository.dart';

void main() {
  CaseSummary study(
    StudyStatus status, {
    int openFailures = 0,
    String? activeRunId,
  }) =>
      mockCases.first.withStatus(
        status: status,
        openFailures: openFailures,
        activeRunId: activeRunId,
      );

  // The run answers as finished, so a Processing page following it reads it
  // once and settles.
  Future<void> open(WidgetTester tester, CaseSummary study) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        processingRepositoryProvider.overrideWithValue(
          FakeProcessingRepository(runs: {
            'run-1': [
              const ProcessingRun(
                status: RunStatus.ready,
                openFailures: 0,
                steps: [],
              ),
            ],
          }),
        ),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => openCase(context, study),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'a study with a run under way opens the Processing page '
      'following that run', (tester) async {
    await open(
      tester,
      study(StudyStatus.processing, activeRunId: 'run-1'),
    );

    final page = tester.widget<ProcessingPage>(find.byType(ProcessingPage));
    expect(page.caseId, 'case-1');
    expect(page.runId, 'run-1');
  });

  testWidgets('a queued study with a run waiting follows that run too',
      (tester) async {
    await open(tester, study(StudyStatus.queued, activeRunId: 'run-1'));

    expect(
      tester.widget<ProcessingPage>(find.byType(ProcessingPage)).runId,
      'run-1',
    );
  });

  testWidgets('a failed study with open failures opens its failed items',
      (tester) async {
    await open(tester, study(StudyStatus.failed, openFailures: 2));

    final page = tester.widget<ProcessingPage>(find.byType(ProcessingPage));
    expect(page.caseId, 'case-1');
    expect(page.runId, isNull);
  });

  testWidgets(
      'a failed study whose failures were all discarded opens Study '
      'Review', (tester) async {
    await open(tester, study(StudyStatus.failed));

    expect(find.byType(ProcessingPage), findsNothing);
    expect(
      tester.widget<StudyReviewPage>(find.byType(StudyReviewPage)).caseId,
      'case-1',
    );
  });

  testWidgets('a ready study with open failures opens Study Review',
      (tester) async {
    await open(tester, study(StudyStatus.ready, openFailures: 3));

    expect(find.byType(StudyReviewPage), findsOneWidget);
    expect(find.byType(ProcessingPage), findsNothing);
  });

  testWidgets(
      'a study processing a review decision, with no run, opens Study '
      'Review', (tester) async {
    await open(tester, study(StudyStatus.processing));

    expect(find.byType(StudyReviewPage), findsOneWidget);
  });
}
