import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';

BoxDecoration _bannerDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).borderRadius != null,
      description: 'banner container',
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Message text ───────────────────────────────────────────────────────────

  testWidgets('message text is shown', (tester) async {
    await tester.pumpWidget(wrap(const StatusBanner(message: 'All systems go')));
    expect(find.text('All systems go'), findsOneWidget);
  });

  // ── Icons per variant ──────────────────────────────────────────────────────

  testWidgets('info: shows info_outline icon', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.info),
    ));
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('warning: shows warning_amber_outlined icon', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.warning),
    ));
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('error: shows error_outline icon', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.error),
    ));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('success: shows check_circle_outline icon', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.success),
    ));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  // ── Background color per variant ───────────────────────────────────────────

  testWidgets('info: background is statusInfoSubdued', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.info),
    ));
    expect(_bannerDecoration(tester).color, AppColorsData.light.statusInfoSubdued);
  });

  testWidgets('warning: background is statusWarningSubdued', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.warning),
    ));
    expect(_bannerDecoration(tester).color, AppColorsData.light.statusWarningSubdued);
  });

  testWidgets('error: background is statusErrorSubdued', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.error),
    ));
    expect(_bannerDecoration(tester).color, AppColorsData.light.statusErrorSubdued);
  });

  testWidgets('success: background is statusSuccessSubdued', (tester) async {
    await tester.pumpWidget(wrap(
      const StatusBanner(message: 'Msg', variant: StatusBannerVariant.success),
    ));
    expect(_bannerDecoration(tester).color, AppColorsData.light.statusSuccessSubdued);
  });

  // ── Dark theme (gap 18) ────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: const Scaffold(
          body: StatusBanner(message: 'Msg', variant: StatusBannerVariant.error),
        ),
      ),
    );
    expect(_bannerDecoration(tester).color, AppColorsData.dark.statusErrorSubdued);
    final message = tester.widget<Text>(find.text('Msg'));
    expect(message.style?.color, AppColorsData.dark.statusError);
  });

  // ── Action button ──────────────────────────────────────────────────────────

  testWidgets('no action button by default', (tester) async {
    await tester.pumpWidget(wrap(const StatusBanner(message: 'Msg')));
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('action button shown when actionLabel and onAction provided', (tester) async {
    await tester.pumpWidget(wrap(StatusBanner(
      message: 'Msg',
      actionLabel: 'Retry',
      onAction: () {},
    )));
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('onAction fires when action button tapped', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(StatusBanner(
      message: 'Msg',
      actionLabel: 'Retry',
      onAction: () => called = true,
    )));
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(called, isTrue);
  });
}
