import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/atoms/app_checkbox.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/failure_row.dart';
import 'package:radiologist_helper/ui/organisms/failure_list.dart';

ProcessingFailure _failure(
  String stepId, {
  int attempts = 1,
  ProcessingStage stage = ProcessingStage.intake,
  ProcessingErrorCode code = ProcessingErrorCode.unsupportedPixelData,
}) =>
    ProcessingFailure(
      stepId: stepId,
      stage: stage,
      internalName: 'img-$stepId',
      code: code,
      attempts: attempts,
      failedAt: DateTime.utc(2026, 11, 22, 10, 14, 3),
      canRetry: true,
    );

void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  final failures = [
    _failure(
      'a',
      attempts: 4,
      stage: ProcessingStage.prediction,
      code: ProcessingErrorCode.modelUnavailable,
    ),
    _failure('b'),
  ];

  Finder selectAll() => find.byWidgetPredicate(
        (w) => w is AppCheckbox && w.semanticLabel == 'Select all',
      );

  bool? selectAllValue(WidgetTester tester) =>
      tester.widget<AppCheckbox>(selectAll()).value;

  testWidgets('counts the failures and shows a row for each', (tester) async {
    await tester.pumpWidget(wrap(FailureList(
      failures: failures,
      selectedIds: const {},
      onSelectionChanged: (_) {},
    )));

    expect(find.text('2 failed items'), findsOneWidget);
    final rows =
        tester.widgetList<FailureRow>(find.byType(FailureRow)).toList();
    expect(rows.map((r) => r.internalName), ['img-a', 'img-b']);
    expect(rows.first.stageLabel, 'Labels');
    expect(rows.first.message, ProcessingErrorCode.modelUnavailable.message);
  });

  testWidgets('says the attempts only when the pipeline retried on its own',
      (tester) async {
    await tester.pumpWidget(wrap(FailureList(
      failures: failures,
      selectedIds: const {},
      onSelectionChanged: (_) {},
    )));
    final rows =
        tester.widgetList<FailureRow>(find.byType(FailureRow)).toList();
    expect(rows.first.meta, 'Tried 4 times · 2026-11-22 10:14 UTC');
    expect(rows.last.meta, '2026-11-22 10:14 UTC');
  });

  testWidgets('a single failure is counted in the singular', (tester) async {
    await tester.pumpWidget(wrap(FailureList(
      failures: [_failure('a')],
      selectedIds: const {},
      onSelectionChanged: (_) {},
    )));
    expect(find.text('1 failed item'), findsOneWidget);
  });

  testWidgets('select all reads none, some or all of the failures',
      (tester) async {
    for (final (selected, expected) in [
      (<String>{}, false),
      ({'a'}, null),
      ({'a', 'b'}, true),
      // An id no longer listed doesn't count.
      ({'a', 'gone'}, null),
    ]) {
      await tester.pumpWidget(wrap(FailureList(
        failures: failures,
        selectedIds: selected,
        onSelectionChanged: (_) {},
      )));
      expect(selectAllValue(tester), expected, reason: '$selected');
    }
  });

  for (final (selected, expected) in [
    (<String>{}, {'a', 'b'}),
    ({'a'}, {'a', 'b'}),
    ({'a', 'b'}, <String>{}),
  ]) {
    testWidgets('select all from $selected selects $expected', (tester) async {
      Set<String>? changed;
      await tester.pumpWidget(wrap(FailureList(
        failures: failures,
        selectedIds: selected,
        onSelectionChanged: (ids) => changed = ids,
      )));
      await tester.tap(find.descendant(
        of: selectAll(),
        matching: find.byType(Checkbox),
      ));
      expect(changed, expected);
    });
  }

  testWidgets('a row adds itself to the selection, and removes itself',
      (tester) async {
    Set<String>? changed;
    await tester.pumpWidget(wrap(FailureList(
      failures: failures,
      selectedIds: const {'a'},
      onSelectionChanged: (ids) => changed = ids,
    )));

    await tester.tap(find.text('img-b'));
    expect(changed, {'a', 'b'});

    await tester.tap(find.text('img-a'));
    expect(changed, <String>{});
  });

  testWidgets('no callback disables the rows and select all', (tester) async {
    await tester.pumpWidget(wrap(FailureList(
      failures: failures,
      selectedIds: const {},
      onSelectionChanged: null,
    )));
    expect(tester.widget<AppCheckbox>(selectAll()).onChanged, isNull);
    expect(
      tester
          .widgetList<FailureRow>(find.byType(FailureRow))
          .map((r) => r.onSelectedChanged),
      everyElement(isNull),
    );
  });

  testWidgets('with no failures, says so and offers nothing to select',
      (tester) async {
    await tester.pumpWidget(wrap(FailureList(
      failures: const [],
      selectedIds: const {},
      onSelectionChanged: (_) {},
    )));
    expect(find.text('No failed items.'), findsOneWidget);
    expect(find.byType(AppCheckbox), findsNothing);
  });

  testWidgets('wraps at 200% text on a 320px screen', (tester) async {
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 320,
        child: FailureList(
          failures: failures,
          selectedIds: const {'a'},
          onSelectionChanged: (_) {},
        ),
      ),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
