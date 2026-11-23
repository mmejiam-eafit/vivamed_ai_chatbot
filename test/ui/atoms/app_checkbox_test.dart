import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_checkbox.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  Checkbox checkbox(WidgetTester tester) =>
      tester.widget<Checkbox>(find.byType(Checkbox));

  testWidgets('reflects each value, including the partly-checked state',
      (tester) async {
    for (final value in [false, true, null]) {
      await tester.pumpWidget(
        wrap(AppCheckbox(value: value, onChanged: (_) {})),
      );
      expect(checkbox(tester).value, value);
      expect(checkbox(tester).tristate, isTrue);
    }
  });

  group('onChanged', () {
    Future<bool?> tapAndCapture(WidgetTester tester, bool? value) async {
      bool? changedTo;
      await tester.pumpWidget(wrap(
        AppCheckbox(value: value, onChanged: (v) => changedTo = v),
      ));
      await tester.tap(find.byType(Checkbox));
      return changedTo;
    }

    testWidgets('unchecked moves to checked', (tester) async {
      expect(await tapAndCapture(tester, false), isTrue);
    });

    testWidgets('checked moves to unchecked', (tester) async {
      expect(await tapAndCapture(tester, true), isFalse);
    });

    testWidgets('partly checked moves to checked', (tester) async {
      expect(await tapAndCapture(tester, null), isTrue);
    });
  });

  testWidgets('no onChanged disables it', (tester) async {
    await tester.pumpWidget(
      wrap(const AppCheckbox(value: false, onChanged: null)),
    );
    expect(checkbox(tester).onChanged, isNull);
  });

  testWidgets('carries its semantic label', (tester) async {
    await tester.pumpWidget(wrap(AppCheckbox(
      value: false,
      onChanged: (_) {},
      semanticLabel: 'Select all',
    )));
    expect(checkbox(tester).semanticLabel, 'Select all');
  });

  testWidgets('its target meets the 44px floor', (tester) async {
    await tester.pumpWidget(wrap(AppCheckbox(value: false, onChanged: (_) {})));
    final size = tester.getSize(find
        .ancestor(
          of: find.byType(Checkbox),
          matching: find.byType(SizedBox),
        )
        .first);
    expect(size.width, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppInteraction.minTouchTarget));
  });

  for (final brightness in Brightness.values) {
    testWidgets('reads the interactive and border tokens ($brightness)',
        (tester) async {
      await tester.pumpWidget(wrap(
        AppCheckbox(value: true, onChanged: (_) {}),
        brightness: brightness,
      ));
      final colors = brightness == Brightness.light
          ? AppColorsData.light
          : AppColorsData.dark;
      expect(checkbox(tester).activeColor, colors.interactivePrimary);
      expect(checkbox(tester).checkColor, colors.interactivePrimaryForeground);
      expect(checkbox(tester).side!.color, colors.border);
    });
  }

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  BoxDecoration ring(WidgetTester tester) => tester
      .widget<Container>(find.descendant(
        of: find.byType(FocusRing),
        matching: find.byType(Container),
      ))
      .decoration! as BoxDecoration;

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(AppCheckbox(value: false, onChanged: (_) {})));
    expect(ring(tester).border!.top.color, Colors.transparent);
  });

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(AppCheckbox(
      value: false,
      onChanged: (_) {},
      focusNode: focusNode,
    )));
    focusNode.requestFocus();
    await tester.pump();

    expect(ring(tester).border!.top.color, AppColorsData.light.borderFocused);
  });
}
