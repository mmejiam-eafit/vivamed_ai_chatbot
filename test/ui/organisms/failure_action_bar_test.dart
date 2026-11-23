import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/failure_action_bar.dart';

void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) => MaterialApp(
        theme: buildAppTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(bottomNavigationBar: child),
        ),
      );

  // By label: a loading AppButton shows a spinner in place of its label.
  Finder button(String label) =>
      find.byWidgetPredicate((w) => w is AppButton && w.label == label);

  AppButton buttonWidget(WidgetTester tester, String label) =>
      tester.widget<AppButton>(button(label));

  FailureActionBar bar({
    int selectedCount = 3,
    int retryableCount = 3,
    VoidCallback? onRetry,
    VoidCallback? onDiscard,
    bool isBusy = false,
  }) =>
      FailureActionBar(
        selectedCount: selectedCount,
        retryableCount: retryableCount,
        onRetry: onRetry ?? () {},
        onDiscard: onDiscard ?? () {},
        isBusy: isBusy,
      );

  testWidgets('counts the selection on both actions', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    expect(find.text('3 selected'), findsOneWidget);
    expect(button('Discard 3'), findsOneWidget);
    expect(button('Retry 3'), findsOneWidget);
  });

  testWidgets('Retry counts only the items that can be retried, and says why',
      (tester) async {
    await tester.pumpWidget(wrap(bar(retryableCount: 2)));
    expect(button('Retry 2'), findsOneWidget);
    expect(
      find.text("1 selected item can't be retried. Upload its file again."),
      findsOneWidget,
    );

    await tester.pumpWidget(wrap(bar(retryableCount: 1)));
    expect(
      find.text("2 selected items can't be retried. Upload their files again."),
      findsOneWidget,
    );
  });

  testWidgets('no hint when everything selected can be retried',
      (tester) async {
    await tester.pumpWidget(wrap(bar()));
    expect(find.textContaining("can't be retried"), findsNothing);
  });

  testWidgets('Retry is disabled when nothing selected can be retried',
      (tester) async {
    await tester.pumpWidget(wrap(bar(retryableCount: 0)));
    expect(buttonWidget(tester, 'Retry 0').onPressed, isNull);
    expect(buttonWidget(tester, 'Discard 3').onPressed, isNotNull);
  });

  testWidgets('Retry fires onRetry', (tester) async {
    var retried = false;
    await tester.pumpWidget(wrap(bar(onRetry: () => retried = true)));
    await tester.tap(button('Retry 3'));
    expect(retried, isTrue);
  });

  testWidgets('Discard asks first, in the bar', (tester) async {
    var discarded = false;
    await tester.pumpWidget(wrap(bar(onDiscard: () => discarded = true)));

    await tester.tap(button('Discard 3'));
    await tester.pump();

    expect(discarded, isFalse);
    expect(
      find.text("Discard 3 items? Discarded items can't be retried."),
      findsOneWidget,
    );
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(button('Discard'));
    await tester.pump();
    expect(discarded, isTrue);
  });

  testWidgets('a single item is asked about in the singular', (tester) async {
    await tester.pumpWidget(wrap(bar(selectedCount: 1, retryableCount: 1)));
    await tester.tap(button('Discard 1'));
    await tester.pump();
    expect(
      find.text("Discard 1 item? Discarded items can't be retried."),
      findsOneWidget,
    );
  });

  testWidgets('Cancel goes back without discarding', (tester) async {
    var discarded = false;
    await tester.pumpWidget(wrap(bar(onDiscard: () => discarded = true)));
    await tester.tap(button('Discard 3'));
    await tester.pump();

    await tester.tap(button('Cancel'));
    await tester.pump();

    expect(discarded, isFalse);
    expect(find.text('3 selected'), findsOneWidget);
  });

  testWidgets('while busy both actions are disabled', (tester) async {
    await tester.pumpWidget(wrap(bar(isBusy: true)));
    expect(buttonWidget(tester, 'Retry 3').onPressed, isNull);
    expect(buttonWidget(tester, 'Discard 3').onPressed, isNull);
  });

  testWidgets('the action running shows it, not the other', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    await tester.tap(button('Retry 3'));
    await tester.pumpWidget(wrap(bar(isBusy: true)));

    expect(buttonWidget(tester, 'Retry 3').isLoading, isTrue);
    expect(buttonWidget(tester, 'Discard 3').isLoading, isFalse);
  });

  testWidgets('a confirmed discard shows it is running', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    await tester.tap(button('Discard 3'));
    await tester.pump();
    await tester.tap(button('Discard'));
    await tester.pumpWidget(wrap(bar(isBusy: true)));

    expect(buttonWidget(tester, 'Discard 3').isLoading, isTrue);
    expect(buttonWidget(tester, 'Retry 3').isLoading, isFalse);
  });

  testWidgets('sits raised above the page', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(FailureActionBar),
          matching: find.byType(Container),
        )
        .first);
    expect(
      (container.decoration! as BoxDecoration).boxShadow,
      AppElevation.raised,
    );
  });

  testWidgets('wraps at 200% text on a 320px screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(bar(retryableCount: 2), textScale: 2.0));
    expect(tester.takeException(), isNull);

    await tester.tap(button('Discard 3'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
