import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/stage_progress_row.dart';

void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: child),
        ),
      );

  AppText text(WidgetTester tester, String value) =>
      tester.widget<AppText>(find.widgetWithText(AppText, value));

  testWidgets('shows the stage and how many of its steps are done',
      (tester) async {
    await tester.pumpWidget(wrap(
      const StageProgressRow(label: 'Labels', done: 5, total: 7),
    ));

    expect(find.text('Labels'), findsOneWidget);
    expect(find.text('5 of 7 done'), findsOneWidget);
    // The count is a figure that lines up across the rows.
    expect(
      text(tester, '5 of 7 done').style!.fontFeatures,
      AppTypography.numeric.fontFeatures,
    );
    expect(text(tester, 'Labels').color, AppColorsData.light.textPrimary);
    expect(
        text(tester, '5 of 7 done').color, AppColorsData.light.textSecondary);
  });

  testWidgets('joins the details on one line', (tester) async {
    await tester.pumpWidget(wrap(const StageProgressRow(
      label: 'Reading the file',
      done: 9,
      total: 12,
      details: ['1 failed', '2 skipped'],
    )));

    expect(find.text('1 failed · 2 skipped'), findsOneWidget);
  });

  testWidgets('shows no detail line without details', (tester) async {
    await tester.pumpWidget(wrap(
      const StageProgressRow(label: 'Labels', done: 7, total: 7),
    ));
    expect(find.byType(AppText), findsNWidgets(2));
  });

  testWidgets('the count sits at the end of the row', (tester) async {
    await tester.pumpWidget(wrap(
      const SizedBox(
        width: 400,
        child: StageProgressRow(label: 'Labels', done: 5, total: 7),
      ),
    ));
    expect(
      tester.getTopRight(find.text('5 of 7 done')).dx,
      tester.getTopRight(find.byType(StageProgressRow)).dx,
    );
    expect(
      tester.getTopLeft(find.text('5 of 7 done')).dy,
      tester.getTopLeft(find.text('Labels')).dy,
    );
  });

  testWidgets('wraps at 200% text on a 320px screen', (tester) async {
    await tester.pumpWidget(wrap(
      const SizedBox(
        width: 320,
        child: StageProgressRow(
          label: 'Similar-case search',
          done: 12,
          total: 12,
          details: ['1 failed', '2 skipped', '1 held back for review'],
        ),
      ),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
