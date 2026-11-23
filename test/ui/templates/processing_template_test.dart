import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/processing_template.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: child));
  }

  const failures = SizedBox(key: Key('failures'), height: 100);
  const progress = SizedBox(key: Key('progress'), height: 100);
  const statusBar = SizedBox(key: Key('status'), height: 40);
  const actionBar = SizedBox(key: Key('actions'), height: 60);

  ProcessingTemplate template({
    Widget? progress,
    Widget? statusBar,
    Widget? actionBar,
  }) =>
      ProcessingTemplate(
        appBar: AppBar(title: const Text('Processing')),
        failures: failures,
        progress: progress,
        statusBar: statusBar,
        actionBar: actionBar,
      );

  testWidgets('renders every slot it is given', (tester) async {
    await pumpAt(
      tester,
      const Size(390, 844),
      template(progress: progress, statusBar: statusBar, actionBar: actionBar),
    );

    expect(find.text('Processing'), findsOneWidget);
    for (final key in ['failures', 'progress', 'status', 'actions']) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
  });

  testWidgets('the optional slots are optional', (tester) async {
    await pumpAt(tester, const Size(390, 844), template());
    expect(find.byKey(const Key('failures')), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNull);
  });

  testWidgets('progress comes first, then the failures', (tester) async {
    await pumpAt(tester, const Size(390, 844), template(progress: progress));
    expect(
      tester.getTopLeft(find.byKey(const Key('progress'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('failures'))).dy),
    );
  });

  testWidgets('the action bar is pinned to the bottom, full width',
      (tester) async {
    await pumpAt(tester, const Size(1280, 800), template(actionBar: actionBar));
    final rect = tester.getRect(find.byKey(const Key('actions')));
    expect(rect.bottom, 800);
    expect(rect.width, 1280);
  });

  testWidgets('the status bar spans the width above the content',
      (tester) async {
    await pumpAt(tester, const Size(1280, 800), template(statusBar: statusBar));
    final rect = tester.getRect(find.byKey(const Key('status')));
    expect(rect.width, 1280);
    expect(
      rect.bottom,
      lessThanOrEqualTo(
          tester.getTopLeft(find.byKey(const Key('failures'))).dy),
    );
  });

  testWidgets('at a phone width the content fills the screen margins',
      (tester) async {
    await pumpAt(tester, const Size(390, 844), template());
    expect(
      tester.getSize(find.byKey(const Key('failures'))).width,
      390 - 2 * AppSpacing.lg,
    );
  });

  testWidgets('on a wide screen the column is capped and centered, top-aligned',
      (tester) async {
    await pumpAt(tester, const Size(1600, 900), template());
    final rect = tester.getRect(find.byKey(const Key('failures')));
    expect(rect.width, AppLayout.contentMaxWidth);
    expect(rect.center.dx, 800);
    // Directly under the app bar and the screen margin, not floating at the
    // window's middle.
    expect(rect.top, kToolbarHeight + AppSpacing.lg);
  });

  testWidgets('keeps the app bar at every width: a drill-down page',
      (tester) async {
    await pumpAt(tester, const Size(1600, 900), template());
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('paints the page ground', (tester) async {
    await pumpAt(tester, const Size(390, 844), template());
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColorsData.light.surfacePage,
    );
  });
}
