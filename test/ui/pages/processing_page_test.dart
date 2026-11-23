import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/processing_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/organisms/failure_action_bar.dart';
import 'package:radiologist_helper/ui/organisms/failure_list.dart';
import 'package:radiologist_helper/ui/organisms/run_progress_card.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

import '../../support/fake_image_review_repository.dart';
import '../../support/fake_processing_repository.dart';

/// Failures that never arrive, for the loading state.
class _PendingFailures extends FakeProcessingRepository {
  @override
  Future<List<StudyFailures>> getFailures() => Completer<Never>().future;
}

class _FailingFailures extends FakeProcessingRepository {
  @override
  Future<List<StudyFailures>> getFailures() async =>
      throw StateError('pipeline down');
}

/// A retry that finishes when the test completes [done].
class _SlowRetry extends FakeProcessingRepository {
  _SlowRetry({super.failures});

  final done = Completer<void>();

  @override
  Future<void> retry(List<String> stepIds) async {
    await done.future;
    return super.retry(stepIds);
  }
}

/// Holds every read of the failures after the first until the test opens
/// [gate]: the list reload after an action.
class _GatedFailures extends FakeProcessingRepository {
  _GatedFailures({super.failures});

  Completer<void>? gate;

  @override
  Future<List<StudyFailures>> getFailures() async {
    if (gate case final gate?) await gate.future;
    return super.getFailures();
  }
}

class _CountingReviews extends FakeImageReviewRepository {
  var reads = 0;

  @override
  Future<List<ImageReview>> getReviews() {
    reads++;
    return super.getReviews();
  }
}

ProcessingFailure _failure(String stepId, {bool canRetry = true}) =>
    ProcessingFailure(
      stepId: stepId,
      stage: ProcessingStage.intake,
      internalName: 'img-$stepId',
      code: canRetry
          ? ProcessingErrorCode.unsupportedPixelData
          : ProcessingErrorCode.unreadableHeader,
      attempts: 1,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14),
      canRetry: canRetry,
    );

ProcessingRun _run(RunStatus status, {int openFailures = 0}) => ProcessingRun(
      status: status,
      openFailures: openFailures,
      steps: const [
        ProcessingStep(
          stage: ProcessingStage.intake,
          state: ProcessingStepState.done,
        ),
      ],
    );

void main() {
  Widget wrap(
    ProcessingRepository repository, {
    String? runId,
    FakeImageReviewRepository? reviews,
  }) =>
      ProviderScope(
        overrides: [
          processingRepositoryProvider.overrideWithValue(repository),
          imageReviewRepositoryProvider
              .overrideWithValue(reviews ?? FakeImageReviewRepository()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: ProcessingPage(caseId: 'case-6', runId: runId),
        ),
      );

  FakeProcessingRepository withFailures(List<ProcessingFailure> failures) =>
      FakeProcessingRepository(failures: [
        (caseId: 'case-6', failures: failures),
        (caseId: 'case-7', failures: [_failure('other')]),
      ]);

  Finder button(String label) =>
      find.byWidgetPredicate((w) => w is AppButton && w.label == label);

  StatusBanner banner(WidgetTester tester) =>
      tester.widget<StatusBanner>(find.byType(StatusBanner));

  group('failed items', () {
    testWidgets('shows a spinner while they load', (tester) async {
      await tester.pumpWidget(wrap(_PendingFailures()));
      await tester.pump();
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.byType(FailureList), findsNothing);
    });

    testWidgets('says when they could not be loaded', (tester) async {
      await tester.pumpWidget(wrap(_FailingFailures()));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Could not load the failed items'),
        findsOneWidget,
      );
    });

    testWidgets('lists only this study\'s failures', (tester) async {
      await tester
          .pumpWidget(wrap(withFailures([_failure('a'), _failure('b')])));
      await tester.pumpAndSettle();

      expect(find.text('2 failed items'), findsOneWidget);
      expect(find.text('img-a'), findsOneWidget);
      expect(find.text('img-other'), findsNothing);
    });

    testWidgets('a study with none says so, with no action bar',
        (tester) async {
      await tester.pumpWidget(wrap(withFailures(const [])));
      await tester.pumpAndSettle();

      expect(find.text('No failed items.'), findsOneWidget);
      expect(find.byType(FailureActionBar), findsNothing);
    });

    testWidgets('opened without a run, shows no progress', (tester) async {
      await tester.pumpWidget(wrap(withFailures([_failure('a')])));
      await tester.pumpAndSettle();
      expect(find.byType(RunProgressCard), findsNothing);
    });
  });

  group('selection', () {
    testWidgets('selecting an item brings up the action bar', (tester) async {
      await tester
          .pumpWidget(wrap(withFailures([_failure('a'), _failure('b')])));
      await tester.pumpAndSettle();
      expect(find.byType(FailureActionBar), findsNothing);

      await tester.tap(find.text('img-a'));
      await tester.pump();

      expect(find.text('1 selected'), findsOneWidget);
      expect(button('Retry 1'), findsOneWidget);
    });

    testWidgets('Retry counts only what can be retried', (tester) async {
      await tester.pumpWidget(wrap(withFailures([
        _failure('a'),
        _failure('b', canRetry: false),
      ])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(find.text('img-b'));
      await tester.pump();

      expect(find.text('2 selected'), findsOneWidget);
      expect(button('Retry 1'), findsOneWidget);
      expect(button('Discard 2'), findsOneWidget);
    });
  });

  group('retry', () {
    testWidgets('retries the selection and says so', (tester) async {
      final repository = withFailures([_failure('a'), _failure('b')]);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pumpAndSettle();

      expect(repository.retried, [
        ['a'],
      ]);
      expect(banner(tester).message, 'Retrying 1 item.');
      expect(banner(tester).variant, StatusBannerVariant.info);
      expect(find.text('img-a'), findsNothing);
      expect(find.byType(FailureActionBar), findsNothing);
    });

    testWidgets('never sends an item that cannot be retried', (tester) async {
      final repository = withFailures([
        _failure('a'),
        _failure('b', canRetry: false),
      ]);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(find.text('img-b'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pumpAndSettle();

      expect(repository.retried, [
        ['a'],
      ]);
    });

    testWidgets('the list and the actions wait while it runs', (tester) async {
      final repository = _SlowRetry(failures: [
        (caseId: 'case-6', failures: [_failure('a')]),
      ]);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pump();

      expect(
        tester.widget<FailureList>(find.byType(FailureList)).onSelectionChanged,
        isNull,
      );
      expect(
        tester.widget<FailureActionBar>(find.byType(FailureActionBar)).isBusy,
        isTrue,
      );

      repository.done.complete();
      await tester.pumpAndSettle();
      expect(find.byType(FailureActionBar), findsNothing);
    });

    testWidgets('a refusal changes nothing and refreshes the list',
        (tester) async {
      final repository = withFailures([_failure('a')])
        ..actionError = const StepConflictException(['a']);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pumpAndSettle();

      expect(
        banner(tester).message,
        '1 selected item had already changed, so nothing was done. '
        'The list has been refreshed.',
      );
      expect(banner(tester).variant, StatusBannerVariant.warning);
      expect(find.text('img-a'), findsOneWidget);
    });

    testWidgets('any other error is reported, and the selection kept',
        (tester) async {
      final repository = withFailures([_failure('a')])
        ..actionError = Exception('offline');
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pumpAndSettle();

      expect(banner(tester).message, 'Could not retry: Exception: offline');
      expect(banner(tester).variant, StatusBannerVariant.error);
      expect(find.text('1 selected'), findsOneWidget);
    });
  });

  group('discard', () {
    testWidgets('discards the whole selection once confirmed', (tester) async {
      final repository = withFailures([
        _failure('a'),
        _failure('b', canRetry: false),
      ]);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find
          .descendant(
            of: find.byType(FailureList),
            matching: find.byType(Checkbox),
          )
          .first);
      await tester.pump();
      await tester.tap(button('Discard 2'));
      await tester.pump();
      expect(repository.discarded, isEmpty);

      await tester.tap(button('Discard'));
      await tester.pumpAndSettle();

      expect(repository.discarded.single, unorderedEquals(['a', 'b']));
      expect(banner(tester).message, 'Discarded 2 items.');
      expect(banner(tester).variant, StatusBannerVariant.success);
      expect(find.text('No failed items.'), findsOneWidget);
    });

    testWidgets('nothing changes until the refreshed list has arrived',
        (tester) async {
      // The reload rebuilds the page while it runs; the outcome must not
      // show beside the old list, nor the selection vanish under it.
      final repository = _GatedFailures(failures: [
        (caseId: 'case-6', failures: [_failure('a')]),
      ]);
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Discard 1'));
      await tester.pump();
      repository.gate = Completer<void>();
      await tester.tap(button('Discard'));
      await tester.pump();
      await tester.pump();

      expect(repository.discarded, [
        ['a'],
      ]);
      expect(find.byType(StatusBanner), findsNothing);
      expect(find.text('img-a'), findsOneWidget);
      expect(
        tester.widget<FailureActionBar>(find.byType(FailureActionBar)).isBusy,
        isTrue,
      );

      repository.gate!.complete();
      await tester.pumpAndSettle();

      expect(banner(tester).message, 'Discarded 1 item.');
      expect(find.text('No failed items.'), findsOneWidget);
      expect(find.byType(FailureActionBar), findsNothing);
    });

    testWidgets('a failed discard is reported', (tester) async {
      final repository = withFailures([_failure('a')])
        ..actionError = Exception('offline');
      await tester.pumpWidget(wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Discard 1'));
      await tester.pump();
      await tester.tap(button('Discard'));
      await tester.pumpAndSettle();

      expect(banner(tester).message, 'Could not discard: Exception: offline');
    });
  });

  group('following a run', () {
    testWidgets('shows the progress, read again until the run ends',
        (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.processing), _run(RunStatus.ready)],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<ProcessingStatusChip>(find.byType(ProcessingStatusChip))
            .status,
        RunStatus.processing,
      );

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<ProcessingStatusChip>(find.byType(ProcessingStatusChip))
            .status,
        RunStatus.ready,
      );
      expect(repository.runReads, 2);
    });

    testWidgets('shows a spinner until the run is first read', (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.ready)],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));

      expect(find.byType(AppLoadingIndicator), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.byType(RunProgressCard), findsOneWidget);
    });

    testWidgets('failures appear on the list as the run reports them',
        (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [
          _run(RunStatus.processing),
          _run(RunStatus.ready, openFailures: 1),
        ],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('No failed items.'), findsOneWidget);

      repository.failures = [
        (caseId: 'case-6', failures: [_failure('a')]),
      ];
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('img-a'), findsOneWidget);
    });

    testWidgets('once the run ends, the review queue is read again',
        (tester) async {
      final reviews = _CountingReviews();
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.processing), _run(RunStatus.ready)],
      });
      await tester.pumpWidget(
        wrap(repository, runId: 'run-1', reviews: reviews),
      );
      // Something on screen reads the reviews, as the navigation does.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProcessingPage)),
      );
      final subscription = container.listen(imageReviewsProvider, (_, _) {});
      addTearDown(subscription.close);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      final readsBefore = reviews.reads;

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(reviews.reads, readsBefore + 1);
    });

    testWidgets('a failed run still offers the study', (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.failed, openFailures: 1)],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('1 open failure'), findsOneWidget);
      expect(button('Open study'), findsOneWidget);
    });

    testWidgets('a read that fails keeps the last progress and says so',
        (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.processing)],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      repository.runError = Exception('offline');
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.byType(RunProgressCard), findsOneWidget);
      expect(
        find.text('Could not refresh the progress: Exception: offline'),
        findsOneWidget,
      );

      // The automatic retry reads again and resumes.
      repository
        ..runError = null
        ..runs['run-1'] = [_run(RunStatus.ready)];
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Ready'), findsOneWidget);
      expect(find.textContaining('Could not refresh'), findsNothing);
    });

    testWidgets('a run that cannot be read at all says so', (tester) async {
      final repository = FakeProcessingRepository(runs: {})
        ..runError = StateError('no such run');
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not load the progress: Bad state: no such run'),
        findsOneWidget,
      );
    });

    testWidgets('a retry follows the reopened run again', (tester) async {
      final repository = FakeProcessingRepository(
        runs: {
          'run-1': [_run(RunStatus.ready, openFailures: 1)],
        },
        failures: [
          (caseId: 'case-6', failures: [_failure('a')]),
        ],
      );
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle();
      final readsBefore = repository.runReads;

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Retry 1'));
      await tester.pumpAndSettle();

      expect(repository.runReads, readsBefore + 1);
    });

    testWidgets('a discard reads the run again, for its new counts',
        (tester) async {
      final repository = FakeProcessingRepository(
        runs: {
          'run-1': [_run(RunStatus.ready, openFailures: 1)],
        },
        failures: [
          (caseId: 'case-6', failures: [_failure('a')]),
        ],
      );
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle();
      final readsBefore = repository.runReads;

      await tester.tap(find.text('img-a'));
      await tester.pump();
      await tester.tap(button('Discard 1'));
      await tester.pump();
      await tester.tap(button('Discard'));
      await tester.pumpAndSettle();

      expect(repository.runReads, readsBefore + 1);
    });

    testWidgets('Open study goes on to Study Review', (tester) async {
      final repository = FakeProcessingRepository(runs: {
        'run-1': [_run(RunStatus.ready)],
      });
      await tester.pumpWidget(wrap(repository, runId: 'run-1'));
      await tester.pumpAndSettle();

      await tester.tap(button('Open study'));
      await tester.pumpAndSettle();

      expect(find.byType(StudyReviewPage), findsOneWidget);
      expect(find.byType(ProcessingPage), findsNothing);
    });
  });
}
