import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders the message', (tester) async {
    await tester.pumpWidget(wrap(const StatusBar(message: 'AI analysis is running…')));
    expect(find.text('AI analysis is running…'), findsOneWidget);
  });

  testWidgets('renders a StatusBanner with the given variant', (tester) async {
    await tester.pumpWidget(wrap(const StatusBar(
      message: 'Low confidence.',
      variant: StatusBannerVariant.warning,
    )));
    final banner = tester.widget<StatusBanner>(find.byType(StatusBanner));
    expect(banner.variant, StatusBannerVariant.warning);
  });

  testWidgets('actionLabel and onAction pass through to StatusBanner',
      (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(StatusBar(
      message: 'Upload failed.',
      variant: StatusBannerVariant.error,
      actionLabel: 'Retry',
      onAction: () => called = true,
    )));
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Background ─────────────────────────────────────────────────────────────

  testWidgets('background uses the surface color, with elevation', (tester) async {
    await tester.pumpWidget(wrap(const StatusBar(message: 'Saved.')));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.light.surface);
    expect(dec.boxShadow, AppElevation.raised);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(body: StatusBar(message: 'Saved.')),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.dark.surface);
  });
}
