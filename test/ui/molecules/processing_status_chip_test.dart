import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/processing_status_chip.dart';

void main() {
  Widget wrap(
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
  }) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  ({Color background, Color foreground}) pairFor(
    AppColorsData colors,
    RunStatus status,
  ) =>
      switch (status) {
        RunStatus.queued || RunStatus.processing => (
            background: colors.statusInfoSubdued,
            foreground: colors.statusInfo,
          ),
        RunStatus.ready => (
            background: colors.statusSuccessSubdued,
            foreground: colors.statusSuccess,
          ),
        RunStatus.failed => (
            background: colors.statusErrorSubdued,
            foreground: colors.statusError,
          ),
      };

  for (final status in RunStatus.values) {
    for (final brightness in Brightness.values) {
      testWidgets('${status.name} ($brightness): label, icon and status pair',
          (tester) async {
        await tester.pumpWidget(wrap(
          ProcessingStatusChip(status: status),
          brightness: brightness,
        ));
        final colors = brightness == Brightness.light
            ? AppColorsData.light
            : AppColorsData.dark;
        final pair = pairFor(colors, status);

        expect(find.text(status.label), findsOneWidget);
        expect(
          find.byIcon(ProcessingStatusChip.iconFor(status)),
          findsOneWidget,
        );
        final container = tester.widget<Container>(find.descendant(
          of: find.byType(ProcessingStatusChip),
          matching: find.byType(Container),
        ));
        expect(
          (container.decoration! as BoxDecoration).color,
          pair.background,
        );
        expect(tester.widget<AppText>(find.byType(AppText)).color,
            pair.foreground);
        expect(tester.widget<AppIcon>(find.byType(AppIcon)).color,
            pair.foreground);
      });
    }
  }

  test('every status has an icon of its own shape', () {
    final icons = RunStatus.values.map(ProcessingStatusChip.iconFor).toSet();
    expect(icons, hasLength(RunStatus.values.length));
  });

  testWidgets('wraps its label at 200% text in a narrow column',
      (tester) async {
    await tester.pumpWidget(wrap(
      const SizedBox(
        width: 80,
        child: ProcessingStatusChip(status: RunStatus.processing),
      ),
      textScale: 2.0,
    ));
    expect(tester.takeException(), isNull);
  });
}
