import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_checkbox.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/failure_row.dart';

void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: child),
        ),
      );

  FailureRow row({
    bool selected = false,
    ValueChanged<bool>? onSelectedChanged,
  }) =>
      FailureRow(
        internalName: '7f3a2101-003',
        stageLabel: 'Labels',
        message: 'A model could not be loaded. Try again later.',
        meta: 'Tried 4 times · 2026-11-22 10:15 UTC',
        selected: selected,
        onSelectedChanged: onSelectedChanged,
      );

  testWidgets('shows the name, the stage with its message, and the meta line',
      (tester) async {
    await tester.pumpWidget(wrap(row(onSelectedChanged: (_) {})));

    expect(find.text('7f3a2101-003'), findsOneWidget);
    expect(
      find.text('Labels: A model could not be loaded. Try again later.'),
      findsOneWidget,
    );
    expect(find.text('Tried 4 times · 2026-11-22 10:15 UTC'), findsOneWidget);
  });

  testWidgets('the name is an identifier, set in mono', (tester) async {
    await tester.pumpWidget(wrap(row(onSelectedChanged: (_) {})));
    final name =
        tester.widget<AppText>(find.widgetWithText(AppText, '7f3a2101-003'));
    expect(name.style!.fontFamily, AppTypography.mono.fontFamily);
    expect(name.maxLines, isNull);
    expect(name.overflow, isNull);
  });

  testWidgets('carries no status color: text on the page tokens',
      (tester) async {
    await tester.pumpWidget(wrap(row(onSelectedChanged: (_) {})));
    final colors = tester
        .widgetList<AppText>(find.byType(AppText))
        .map((t) => t.color)
        .toSet();
    expect(
      colors,
      {AppColorsData.light.textPrimary, AppColorsData.light.textSecondary},
    );
  });

  testWidgets('reflects selected on its checkbox', (tester) async {
    await tester
        .pumpWidget(wrap(row(selected: true, onSelectedChanged: (_) {})));
    expect(tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value, isTrue);
  });

  for (final selected in [false, true]) {
    testWidgets('a tap on the text toggles it (from $selected)',
        (tester) async {
      bool? changedTo;
      await tester.pumpWidget(wrap(row(
        selected: selected,
        onSelectedChanged: (v) => changedTo = v,
      )));
      await tester.tap(find.text('7f3a2101-003'));
      expect(changedTo, !selected);
    });
  }

  testWidgets('a tap on the checkbox toggles it', (tester) async {
    bool? changedTo;
    await tester.pumpWidget(wrap(row(onSelectedChanged: (v) => changedTo = v)));
    await tester.tap(find.byType(Checkbox));
    expect(changedTo, isTrue);
  });

  testWidgets('no callback disables the row and its checkbox', (tester) async {
    await tester.pumpWidget(wrap(row()));
    expect(tester.widget<InkWell>(find.byType(InkWell).first).onTap, isNull);
    expect(
      tester.widget<AppCheckbox>(find.byType(AppCheckbox)).onChanged,
      isNull,
    );
  });

  testWidgets('is one checkbox to assistive technology, labelled by its text',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester
        .pumpWidget(wrap(row(selected: true, onSelectedChanged: (_) {})));

    expect(
      tester.getSemantics(find.byType(MergeSemantics)),
      isSemantics(
        hasCheckedState: true,
        isChecked: true,
        label: '7f3a2101-003\n'
            'Labels: A model could not be loaded. Try again later.\n'
            'Tried 4 times · 2026-11-22 10:15 UTC',
      ),
    );
    handle.dispose();
  });

  testWidgets('wraps at 200% text on a 320px screen', (tester) async {
    await tester.pumpWidget(wrap(
      SizedBox(width: 320, child: row(onSelectedChanged: (_) {})),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
