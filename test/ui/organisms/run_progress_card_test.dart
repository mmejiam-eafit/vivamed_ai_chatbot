import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/processing_status_chip.dart';
import 'package:radiologist_helper/ui/molecules/stage_progress_row.dart';
import 'package:radiologist_helper/ui/organisms/run_progress_card.dart';

ProcessingStep _step(ProcessingStage stage, ProcessingStepState state) =>
    ProcessingStep(stage: stage, state: state);

ProcessingRun _run({
  RunStatus status = RunStatus.ready,
  int openFailures = 0,
  List<ProcessingStep> steps = const [],
}) =>
    ProcessingRun(status: status, openFailures: openFailures, steps: steps);

void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  testWidgets('shows the run status', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(status: RunStatus.processing),
    )));
    final chip = tester.widget<ProcessingStatusChip>(
      find.byType(ProcessingStatusChip),
    );
    expect(chip.status, RunStatus.processing);
  });

  testWidgets('counts the open failures next to the status', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(openFailures: 2),
    )));
    expect(find.text('2 open failures'), findsOneWidget);

    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(openFailures: 1),
    )));
    expect(find.text('1 open failure'), findsOneWidget);
  });

  testWidgets('says nothing about failures when none is open', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(run: _run())));
    expect(find.textContaining('open failure'), findsNothing);
  });

  testWidgets('shows one row per stage that has steps, with its details',
      (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(steps: [
        _step(ProcessingStage.intake, ProcessingStepState.done),
        _step(ProcessingStage.intake, ProcessingStepState.failed),
        _step(ProcessingStage.intake, ProcessingStepState.skipped),
        _step(ProcessingStage.viewCheck, ProcessingStepState.heldBack),
        _step(ProcessingStage.viewCheck, ProcessingStepState.discarded),
      ]),
    )));

    final rows = tester
        .widgetList<StageProgressRow>(find.byType(StageProgressRow))
        .toList();
    expect(rows.map((r) => r.label), ['Reading the file', 'View check']);
    expect(rows.first.done, 1);
    expect(rows.first.total, 3);
    expect(rows.first.details, ['1 failed', '1 skipped']);
    expect(rows.last.details, ['1 held back for review', '1 discarded']);
  });

  testWidgets('Open study shows only when given, and fires', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(run: _run())));
    expect(find.text('Open study'), findsNothing);

    var opened = false;
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(),
      onOpenStudy: () => opened = true,
    )));
    await tester.tap(find.text('Open study'));
    expect(opened, isTrue);
  });

  testWidgets('says when the progress could not be refreshed', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(),
      refreshError: 'Could not refresh the progress: offline',
    )));
    expect(
      find.text('Could not refresh the progress: offline'),
      findsOneWidget,
    );
  });

  testWidgets('a run with no steps yet shows only its status', (tester) async {
    await tester.pumpWidget(wrap(RunProgressCard(
      run: _run(status: RunStatus.queued),
    )));
    expect(find.byType(StageProgressRow), findsNothing);
    expect(find.text('Queued'), findsOneWidget);
  });

  testWidgets('wraps at 200% text on a 320px screen', (tester) async {
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 320,
        child: RunProgressCard(
          run: _run(openFailures: 2, steps: [
            _step(ProcessingStage.embedding, ProcessingStepState.failed),
          ]),
          onOpenStudy: () {},
        ),
      ),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
